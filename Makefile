
ll:
	arm-none-eabi-as -mthumb -mcpu=cortex-m4 round_robbin.s -o round_robbin.o
	arm-none-eabi-ld -Map=round_robbin.map -Tlinker.ld  round_robbin.o -o round_robbin.elf
	arm-none-eabi-readelf -a round_robbin.elf >round_robbin.debug	
	arm-none-eabi-objcopy -O binary round_robbin.elf round_robbin.bin	
	arm-none-eabi-nm round_robbin.elf >round_robbin.nm

clean:
	rm -rf *.elf *.o *.debug *.bin *.nm *.map
