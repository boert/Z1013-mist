for a succesful simulation following things are needed:
- vmk tool (to generate dependencies): https://sourceforge.net/projects/vmk/
- Modelsim binarys (vlib, vcom, vlog, vsim) in $PATH
- patience (at least for a system simulation with the Modelsim Altera Edition)

obsolete:
- a mixed language license --> all project files are exists in vhdl version


getting started with simulation:

(re-)compile all files with:
```
make
```

start simulation with:
```
make simulate

```
restart simulation in the Modelsim TCL console with:
```
r
```
