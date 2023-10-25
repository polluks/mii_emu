; Smartport Firmware for MII
; This is included in the MII ROM by mii_smartport.c
;
; This is shamelessly lifted and heavily adapted from
; https:github.com/ct6502/apple2ts/blob/main/src/emulator/harddrivedata.ts
; With inspiration from Terence Boldt's driver for the ROM card
;
; ProDOS defines
command 	=	$42		; ProDOS command
unit  		=	$43		; 7=drive 6-4=slot 3-0=not used
buflo 		=	$44		; low address of buffer
bufhi 		=	$45		; hi address of buffer
blklo 		=	$46		; low block
blkhi 		=	$47		; hi block
ioerr 		=	$27		; I/O error code
nodev 		=	$28		; no device connected
wperr 		=	$2B		; write protect error
knownRts	=	$FF58
		.org 	$c000
		.verbose
entryOffset	=	$c0		; entry point offset
		ldx		#$20    ; Apple IIe looks for magic bytes $20, $00, $03.
		lda		#$00    ; These indicate a disk drive or SmartPort device.
		ldx		#$03
		lda		#$00    ; $3C=disk drive, $00=SmartPort
start:
		bit		$CFFF   ; Trigger all peripheral cards to turn off expansion ROMs
		ldy 	#$0
		sty		buflo
		sty		blklo
		sty		blkhi
		iny				;set command = 1 for read block
		sty		command
		lda		#$4C    ; jmp
		sta		$07FD
		lda		#entryOffset   ; jump address
		sta		$07FE
		jsr		knownRts
		tsx
		lda		$100,X  ; High byte of slot adddress
		sta		$07FF   ; Store this for the high byte of our jmp command
		asl				; Shift $Cs up to $s0 (e.g. $C7 -> $70)
		asl				; We need this for the ProDOS unit number (below).
		asl				; Format = bits DSSS0000
		asl				; D = drive number (0), SSS = slot number (1-7)
		sta		unit	; Store ProDOS unit number here
		lda		#$08    ; Store block (512 bytes) at address $0800
		sta		bufhi	; Address high byte
		stz		buflo	; Address low byte
		stz		blklo	; Block 0 low byte
		stz		blkhi	; Block 0 high byte
		jsr		$07FD   ; Read the block (will jmp to our driver and trigger it)
		bcs		error
		lda		#$0A	; Store block (512 bytes) at address $0A00
		sta		bufhi	; Address high byte
		lda		#$01
		sta		blklo	; Block 1 low byte
		jsr		$07FD	; Read
		bcs		error
		lda		$0801	; Should be nonzero
		beq		error
		lda		#$01	; Should always be 1
		cmp		$0800
		bne		error
		ldx		unit	; ProDOS block 0 code wants ProDOS unit number in X
		jmp		$801	; Continue reading the disk
error	jmp		$E000	; Out to BASIC on error

		.org	$c0c0
; jump back to mii code
entryHD	nop				; Hard drive driver address
		bra		magicHD
		bra		magicSM

		.org	$c0d0
magicHD	.db 	$db, $fb, $0
		bra		done

		.org	$c0e0
magicSM	.db 	$db, $fb, $0
		bra		done

		.org	$c0f0
DONE	bcs		ERR
		lda		#$00
		rts
ERR		lda		#$27
		rts

; $CnFE status byte
;  bit 7 - Medium is removable.
;  bit 6 - Device is interruptable.
;  bit 5-4 - Number of volumes on the device (0-3).
;  bit 3 - The device supports formatting.
;  bit 2 - The device can be written to.
;  bit 1 - The device can be read from (must be on).
;  bit 0 - The device's status can be read (must be on).
		.org	$c0fe
		.db		$17
		.db		entryOffset		; entry point offset
