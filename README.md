#### 接口设计实验 - Proteus 设计并仿真

`Project/` 中是 proteus 工程文件，包括各个实验的完整原理设计图，可用于仿真

`src/` 中是各个实验需要的 8086 运行程序，自行编译，例如

```
nasm -f bin lab.asm -o lab1.bin
nasm.exe -f bin lab1.asm -o lab1.bin
```

然后在对应实验的工程中，将 .bin 载入 8086 即可，设置好 8086 的合适内存大小即可仿真

