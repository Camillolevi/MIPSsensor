.data
.align 2


# Input Text
distanzaIN : .asciiz "distanzaIN.txt"
pendenzaIN : .asciiz "pendenzaIN.txt"
sterzoIN : .asciiz "sterzoIN.txt"


# Output Text
distanzaOUT : .asciiz "distanzaOUT.txt"
pendenzaOUT : .asciiz "pendenzaOUT.txt"
sterzoOUT : .asciiz "sterzoOUT.txt"

correttezzaP1 : .asciiz "correttezzaP1.txt"
correttezzaP2 : .asciiz "correttezzaP2.txt"
correttezzaP3 : .asciiz "correttezzaP3.txt"


# String Data
FNF : .asciiz "ERROR : File not found >> "
newLine : .asciiz "\n"


.text
.globl main


### PROCEDURA MAIN ###

main :
	addi	$sp, $sp, -36
  sw	$s0, 0($sp)
  sw	$s1, 4($sp)
  sw	$s2, 8($sp)
  sw	$s3, 12($sp)
  sw	$s4, 16($sp)
  sw	$s5, 20($sp)
  sw	$s6, 24($sp)
  sw	$s7, 28($sp)
  sw	$ra, 32($sp)

  move   $s0, $zero	    # resetto eventuale contenuto presente in $s0
  la	$a0, distanzaIN	  # carico in $a0 il FilePath di "ditanzaIN.txt"
  jal	controlloFileIN	  # e lo passo alla procedura che mi fornirà un indirizzo in cui verranno memorizzati
                        # i byte contenuti nel file di testo
  move   $s1, $v0		     # <--- salvo tale indirizzo in $s1

  add	$s0, $s0, $v1	     # se si verifica un errore in fase di caricamento <--> $v1 > 0

  la	$a0, pendenzaIN	   # carico in $a0 il FilePath di "pendenzaIN.txt"
  jal	controlloFileIN	   # e lo passo alla procedura che mi fornirà un indirizzo in cui verranno memorizzati
	                       # i byte contenuti nel file di testo
  move   $s2, $v0		     # <--- salvo tale indirizzo in $s2

  add	$s0, $s0, $v1	     # se si verifica un errore in fase di caricamento <--> $v1 > 0

  la	$a0, sterzoIN	     # carico in $a0 il FilePath di "sterzoIN.txt"
  jal	controlloFileIN	   # e lo passo alla procedura che mi fornirà un indirizzo in cui verranno memorizzati
	                       # i byte contenuti nel file di testo
  move   $s3, $v0	       # <--- salvo tale indirizzo in $s3

  add	$s0, $s0, $v1	     # se si verifica un errore in fase di caricamento <--> $v1 >0

  bgtz	$s0, termineEsecuzione_main

  li	$v0, 9		# Chiamata a sistema : SBRK
  li	$a0, 300	# alloco in $v0 300byte in cui andrò a scrivere i vari risultati
  syscall			# sul controllo dei sensori

  move  $s0, $v0


cicloEsecuzione_main :
  beq	$s7, 100, fineCiclo_main	# se abbiamo terminato la 101a iterazione, si esce dal ciclo
  addi	$sp, $sp, -1		       	# per poter eseguire una valutazione, mi è necessario salvare spazio per un byte
  lb	$t0, 0($s1)		          	# nello StackPointer, ossia il byte contenente la tipologia dell'ostacolo da valutare
  sb	$t0, 0($sp)		          	# (  $t0 = distanzaIN [ $s1 ]  )
  addi	$s1, $s1, 1		        	# aumento di 1 il valore dell'indirizzo in $s1
  move   $a0, $s1			        	# $a0 = argomento della funzione : indirizzo di partenza da cui iterare

  jal	valutazione_FileIN

  move   $s1, $v1			        	# cambio il valore in $s1 col nuovo indirizzo trovato dalla funzione
  move   $t0, $v0			        	# $t0 = valore da controllare
  lb	$t1, 0($sp)		          	# $t1 = tipologia ostacolo
  addi	$sp, $sp 1		         	# ripristino StackPointer
  beq	$t1, 65, ostacoloFisso		# se l'ostacolo è di tipo Fisso, salto all'etichetta corretta per l'esecuzione
  beq	$t0, $s4, ostacoloMobile_ripetizione	# se la lettura corrente e quella precedente coincidono, si aggiorna il contatore
  move   $s4, $t0			        	# aggiorno l'ultima lettura effettuata
  move   $s5, $zero		         	# resetto il contatore delle ripetizioni
  j	distanza_controllo


ostacoloMobile_ripetizione :
  addi	$s5, $s5, 1			                # aumento indice di ripetizione di ostacoli mobili
  bge	$s5, 2, distanzaIN_fallimento	    # se contatore > 1, si segnala un malfunzionamento
  j	distanza_controllo


ostacoloFisso :
  move   $s4, $zero		       	# resetto $s4 = ultima lettura sul sensore distanza effettuta
  move   $s5, $zero		       	# resetto $s5 = numero di ripetizioni di medesima lettura mobile


distanza_controllo :
  bgt	$t0, 5150, distanzaIN_fallimento  	# se $t0 > 5150 ( 50 in base decimale ) segnalo malfunzionamento
  li	$t1, 48				                    	# caricon in $t1 il valore 48 da poterlo usare come divisore nella prossima istruzione
  div	$t0, $t1			                     	# divido $t0 per 48 : se il resto di tale operazione è 0, segnalo malfunzionamento
  mfhi	$t1				                      	# $t1 = resto divisione
  beqz	$t1, distanzaIN_fallimento		    # resto = 0 -> risultato = 48 o 4848 o 484848 o 48484848 o ...


distanzaIN_successo :
  li	$t0, 49			         	# carico in $t0 il valore 49 (ascii : 1)
  sb	$t0, 0($s0)		      	# e lo carico in posizione [ $s0 ]
  addi	$s0, $s0, 1		    	# ed incremento indice $s0
  j	pendenza_esecuzione


distanzaIN_fallimento :
  li	$t0, 48			         	# carico in $t0 il valore 48 (ascii : 0)
  sb	$t0, 0($s0)		      	# e lo carico in posizione [ $s0 ]
  addi	$s0, $s0, 1		    	# ed incremento indice $s0


pendenza_esecuzione  :
  lb	$t0, 0($s2)		                      	# carico in $t0 il valore in [ $s2 ]
  bne	$t0, 45, pendenza_skipSegno	          # se si tratta del segno '-' (meno) incremento l'indice $s2
  addi	$s2, $s2, 1			                    # atrimenti proseguo normalmente


pendenza_skipSegno :
  move   $a0, $s2			                    	# $a0 = parametro da passare alla funzione seguente
  jal	valutazione_FileIN		                # a fine esecuzione, $v0 = risultato codificato, $v1 = nuovo indice da cui ricominciare
  move   $s2, $v1			    	                # salvo in $s2 il nuovo indirizzo che mi è stato fornito
  move   $t0, $v0			                    	# salvo il risultato in $t0. Poichè il risultato esce senza segno,
	                                          # si controlla esclusivamente che questo non sia superiore al valore indicato
  bgt	$t0, 5457, pendenza_fallimento	      # dalle specifiche, ossia 5457  ( 59 in base decimale )
  li	$t0, 49				                        # carico in $t0 il valore 49 (ascii : 1)
  sb	$t0, 0($s0)		                      	# e lo carico in posizione [ $s0 ]
  addi	$s0, $s0, 1		                    	# ed incremento indice $s0
  j	sterzo_esecuzione


pendenza_fallimento :
  li	$t0, 48			       	# carico in $t0 il valore 48 (ascii : 0)
  sb	$t0, 0($s0)			    # e lo carico in posizione [ $s0 ]
  addi	$s0, $s0, 1			  # ed incremento indice $s0


sterzo_esecuzione :
  move  $a0, $s3				             # $a0 = parametro da passare alla funzione seguente
  jal	valutazione_FileIN		         # a fine esecuzione, $v0 = risultato codificato, $v1 = nuovo indice da cui ricominciare
  move   $t0, $v0			               # $t0 = risultato funzione
  move   $s3, $v1				             # salvo in $s3 il nuovo indirizzo che mi è stato fornito
  addi	$t0, $t0, -48			           # Poichè la codifica adottata non consente l'operazione di somma,
  blt	$t0, 4800, sterzo_decodifica	 # è necessario trasformare il numero trovato in base 10.
  addi	$t0, $t0, -4800		           # Per fare ciò, occore sottrarre 48 e, se il numero è sufficientemente
                                     # grande dopo l'operazione, sottrarre il valore 4800.

sterzo_decodifica :
  li	$t1, 10				                  # A questo punto dividiamo per 10 numero rimasto e vi sommiamo
  div	$t0, $t0, $t1		               	# resto ottenuto dalla divisione
  mfhi	$t1				                    # carico in $t1 il valore 10 per eseguire una divisione
  add	$t0, $t0, $t1
  beq	$s7, 0, sterzo_primaLettura	    # se il ciclo iterativo è 0, non posso confrontare con la lettura precedente
  sub	$t1, $t0, $s6		               	# $t1 = (lettura corrente) - (lettura precedente)
  bge	$t1, 0, sterzo_continuazione  	# se $t1 > 0 non eseguo ulteriori modifiche, altrimenti
  sub	$t1, $zero, $t1		             	# calcolo la controparte positiva del risultato


sterzo_continuazione :
  move   $s6, $t0			              	# aggiorno ultima lettura del sensore sterzos
  ble	$t1, 10, sterzo_successo	      #se la differenza <= 10, segnalo il successo, altrimenti malfunzionamento
  j	sterzo_fallimento


sterzo_primaLettura :
  move   $s6, $t0				# aggiorno ultima lettura del sensore sterzo


sterzo_successo :
  li	$t0, 49			     	# carico in $t0 il valore 49 (ascii : 1)
  sb	$t0, 0($s0)		  	# e lo carico in posizione [ $s0 ]
  addi	$s0, $s0, 1			# ed incremento indice $s0
  j	incremento_iteratore


sterzo_fallimento :
  li	$t0, 48				    # carico in $t0 il valore 48 (ascii : 0)
  sb	$t0, 0($s0)			  # e lo carico in posizione [ $s0 ]
  addi	$s0, $s0, 1			# ed incremento indice $s0


incremento_iteratore :
  addi	$s7, $s7, 1			# incremento indice ciclo di 1 unità
  j	cicloEsecuzione_main


fineCiclo_main :
  sub	$s0, $s0, $s7		   	# ripristino indice di partenza di $s0 per passarlo come argomento successivamente
  sub	$s0, $s0, $s7
  sub	$s0, $s0, $s7
  move   $a0, $s0				  # $a0 = parametro contenente la prima lettura del sensore che vogliamo scrivere
  la	$a1, distanzaOUT		# $a1 = FilePath destinazione

  jal	scrittura_FileOUT

  addi	$s0, $s0, 1		  	# incremento indice $s0 di 1 unità, così da puntare ai risultati del sensore pendenza
  move   $a0, $s0				  # $a0 = parametro contenente la prima lettura del sensore che vogliamo scrivere
  la	$a1, pendenzaOUT		# $a1 = FilePath destinazione

  jal	scrittura_FileOUT

  addi	$s0, $s0, 1		  	# incremento indice $s0 di 1 unità, così da puntare ai risultati del sensore pendenza
  move   $a0, $s0			  	# $a0 = parametro contenente la prima lettura del sensore che vogliamo scrivere
  la	$a1, sterzoOUT			# $a1 = FilePath destinazione
  jal	scrittura_FileOUT

  addi	$s0, $s0, -2			# ripristino $s0 in posizione iniziale
  la	$a0, correttezzaP1	# carico in $a0 il FilePath dove scrivere i risultati
  li	$a1, 147			      # $a1 = risultato da conseguire per corretto funzionamento
  move   $a2, $s0			  	# $a2 = indirizzo di partenza per controllo del sistema
  jal	scrittura_correttezza

  la	$a0, correttezzaP2		# carico in $a0 il FilePath dove scrivere i risultati
  li	$a1, 146			        # $a1 = risultato da conseguire per corretto funzionamento
  move   $a2, $s0				    # $a2 = indirizzo di partenza per controllo del sistema
  jal	scrittura_correttezza

  la	$a0, correttezzaP3		# carico in $a0 il FilePath dove scrivere i risultati
  li	$a1, 145		         	# $a1 = risultato da conseguire per corretto funzionamento
  move   $a2, $s0			     	# $a2 = indirizzo di partenza per controllo del sistema
  jal	scrittura_correttezza



termineEsecuzione_main :
  lw	$s0, 0($sp)
  lw	$s1, 4($sp)
  lw	$s2, 8($sp)
  lw	$s3, 12($sp)
  lw	$s4, 16($sp)
  lw	$s5, 20($sp)
  lw	$s6, 24($sp)
  lw	$s7, 28($sp)
  lw	$ra, 32($sp)
  addi	$sp, $sp, 36

  jr	$ra


#################### 			CONTROLLO FILE IN			####################

controlloFileIN :
  li	 $v0, 13			    # istruzione di caricamento di un file
  move $a1, $zero				# comunica essere file di sola lettura
  move $a2, $zero				# (ignored)
  syscall

  beq	$v0, -1, controlloFile_fallimento	    # verifica problema in fase di caricamento
  move   $t0, $v0				                   	# salvo temporaneamente $v0 in $t0 per riutilizarlo in seguito
  li	$v0, 9				                       	# Allocazione Dinamica della Memoria SBRK
  li	$a0, 1024			                       	# di 1KB di informazione
  syscall

  move   $a1, $v0				 # $a1 = indirizzo su cui scrivere il contenuto del FileIN
  li	$v0, 14					   # istruzione di lettura di un file
  move   $a0, $t0				 # $a0 = File Descriptor
  li	$a2, 1024				   # specifico lunghezza massima da leggere
  syscall

  li $v0, 16				     # chiudo Distanza Despriptor (che si trova già in $a0)
  syscall

  li	$v1, 0				     # $v1 = 0  <--> non ci sono stati errori durante la fase di caricamento
  move   $v0, $a1				 # $a1 contiene ancora l'indirizzo da cui è scritto il contenuto del FileIN
  jr	$ra


controlloFile_fallimento :
  move   $t0, $a0					# copio FilePath in $t0 per riutilizzarlo a breve
  li	$v0, 4				     	# stampo nella console l'avvertimento
  la	$a0, FNF			    	# che comunica all'utente di non aver trovato il file richiesto
  syscall

  move   $a0, $t0					# $a0 = FilePath non corretto
  syscall

  la	$a0, newLine				# stampo " \n "
  syscall


  li	$v1, 1					    # $v1 = 1 sta ad indicare che c'è stato un problema in fase di caricamento
  jr	$ra


#################### 		    CODIFICA CONTENUTO			####################

valutazione_FileIN :
  move   $t0, $zero				# $t0 conterrà il valore della lettura (azzerato ad inizio procedura)
  move   $t1, $a0					# copio l'indirizzo fornito in $t1


valutazioneFileIN_ciclo :
  lb	$t3, 0($t1)			                       	# carico in $t3 il valore puntato da $t1
  addi	$t1, $t1, 1				                    # incremento indice posizionale sulla stringa
  beq	$t3, 32, valutazioneFileIN_fineCiclo		# se $t3 = 'spazio' sono arrivato a fine lettura e posso uscire dal ciclo
  beq	$t3, 0,  valutazioneFileIN_fineCiclo		# se $t3 = 'null' sono arrivato a fine lettura e posso uscire dal ciclo
  mul  $t0, $t0, 100					               	# shifto il valore della lettura a sx di 2 spazi moltiplicandola per 100
  add	$t0, $t0, $t3				                   	# aggiungo il valore letto a quello parziale
  j	valutazioneFileIN_ciclo


valutazioneFileIN_fineCiclo :
  move   $v0, $t0					# $v0 contiene il risultato della funzione
  move   $v1, $t1					# $v1 contiene l'indirizzo da cui partire alla prossima iterazione

  jr	$ra


#################### 		    SCRITTURA SENSORI			####################

scrittura_FileOUT :
  move   $t0, $a0					# salvo indirizzo di partenza
  move   $t4, $a1					# salvo in $t4 la stringa contenente il FilePath di scrittura
  li	$v0, 9				     	# Chiamata a sistema SBRK
  li	$a0, 200			    	# alloco 200 byte di memoria in cui salvare i risultati ottenuti
  syscall

  move   $t1, $v0					# $t1 è l'indirizzo di partenza di memoria su cui cominciare a scrivere
  move   $t2, $v0					# ne salvo una copia
  move   $t8, $zero				#$t8 = contatore (azzerato)


scritturaFile_ciclo :
  beq	$t8, 100, scritturaFile_fineCiclo
  lb	$t3, 0($t0)			 	                     # $t3 = risultati [ $t0 ]
  sb	$t3, 0($t1)				                     # carico il valore in $t3 all'indirizzo di memoria in cui salvare i risultati del sensore
  addi	$t0, $t0, 3			                     # incremento di 3 l'indice di lettura di tutti i risultati
  addi	$t1, $t1, 1				                   # incremento di 1 l'indice di scrittura dei risultati del sensore specifico
  li	$t3, 32					                       # carico in $t3 il valore 32 ( ascii : ' ' )
  sb	$t3, 0($t1)			                       # carico il simbolo dello spazio nel buffer dei risultati
  addi	$t1, $t1, 1			                     # incremento di 1 l'indice di scrittura dei risultati del sensore specifico
  addi	$t8, $t8, 1

  j	scritturaFile_ciclo


scritturaFile_fineCiclo :
  li	$v0,	13			     	# chiamata a sistema : Apertura File
  move   $a0, $t4					# apro il file che mi è stato indicato in $a1
  li	$a1, 1					    # comunico che voglio scrivere un file
  li	$a2, 0
  syscall

  move   $t0, $v0					# salvo File Descriptor in $t0
  li	$v0, 15				    	# chiamata a sistema : Scrittura File
  move   $a0, $t0					# passo il File Descriptor
  move   $a1, $t2					# comunico dove scrivere i risultati
  li	$a2, 200			    	# comunico di voler scrivere 200 caratteri
  syscall

  li	$v0, 16
  syscall

  jr	$ra


#################### 		    SCRITTURA SISTEMA			####################

scrittura_correttezza :
  move   $t4, $a0					# $t4 = FilePath
  move   $t5, $a1					# $t5 = risultato da raggiungere
  move   $t0, $a2					# $t0 = indirizzo di partenza

  li	$v0, 9					# Chiamata a sistema : SBRK
  li	$a0, 199				# richiedo 199 byte su cui scrivere i risultati
  syscall

  move   $t6, $v0					# $t6 = indirizzo base da cui iniziare a scrivere
  move   $t7, $v0					# salvo una copia in $t7
  move   $t8, $zero


correttezza_ciclo :
  beq	$t8, 100, correttezza_uscitaCiclo
  lb	$t1, 0($t0)				                  # $t1 = risultato sensore distanza
  addi	$t0, $t0, 1				                #incremento indice su buffer risultati
  lb	$t2, 0($t0)			                   	# $t2 = risultato sensore pendenza
  addi	$t0, $t0, 1			                 	#incremento indice su buffer risultati
  lb	$t3, 0($t0)			                   	# $t3 = risultato sensore sterzo
  addi	$t0, $t0, 1			                 	#incremento indice su buffer risultati (indirizzo inizio di una nuova terna)
  add	$t1, $t1, $t2
  add	$t1, $t1, $t3			                	# $t1 = $t1 + $t2 + $t3
  bge	$t1, $t5, correttezza_fallimento	  # se non ho raggiunto il valore necessario, comunico il fallimento
  li	$t1, 48				                    	# carico in $t1 il valore 48 ( ascii : 0 )

  j	correttezza_scritturaRisultato


correttezza_fallimento :
  li	$t1, 49 			    	# carico in $t1 il valore 49 ( ascii : 1 )


correttezza_scritturaRisultato :
  sb	$t1, 0($t6)			 	  # carico risultato nel buffer dei risultati
  addi	$t6, $t6, 1				# incremento indice sul buffer
  li	$t1, 32					    # carico in $t1 il valore 32 ( ascii : spazio )
  sb	$t1, 0($t6)			   	# carico lo 'spazio' nel buffer dei risultati
  addi	$t6, $t6, 1				# incremento indice del buffer
  addi	$t8, $t8, 1

  j	correttezza_ciclo


correttezza_uscitaCiclo :
  li	$v0, 13				    	# Chiamata a sistema : Apertura File
  move   $a0, $t4					# comunico il FilePath del file da aprire
  li	$a1, 1				     	# comunico essere file di scrittura
  li	$a2, 0
  syscall

  move   $t0, $v0					# copio File Descriptor in $t0
  li	$v0, 15				    	# Chiamata a sistema : Scrittura nel File
  move   $a0, $t0					# $a0 = File Descriptor
  move   $a1, $t7					# $a1 = buffer dei risultati da stampare
  li	$a2, 199			     	# comunico di voler stampare 199 byte
  syscall

  li	$v0, 16				    	# Chiamata a sistema : Chiusura File Descriptor
  syscall

jr	$ra
