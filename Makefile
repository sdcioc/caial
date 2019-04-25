# Writed by Wu Wanquan
# setting about this program
APP = KNN				# name of this program
FILES =  KNN/KNN.c    # files that need to compile (they will not be compile separately)
OPTFLAGS = -O2

# --------------------------------------------
include ../Makefile.inc		# include Makefile.inc here

$(APP): $(FILES)
	$(CC) $(INCS) $(CFLAGS) -O0 -o $@.riscv $(FILES) $(OSRCS) $(LFLAGS)
	$(RISCV_OBJDUMP) $@.riscv > $@.riscv.dump

$(APP)_opted: $(FILES)
	$(CC) $(INCS) $(CFLAGS) $(OPTFLAGS) -o $@.riscv $(FILES) $(OSRCS) $(LFLAGS)
	$(RISCV_OBJDUMP) $@.riscv > $@.riscv.dump

sim: $(APP).riscv
	$(SIM) $<
	# start simulation without cycle-by-cycle log
	# output of program will be directly write to console

simv: $(APP).riscv
	$(SIM) +verbose $< $(VERBOSE_TO_FILE)
	# start simulation
	# output of program > simv.stdout
	# cycle-by-cycle log > simv.log
	
simopt: $(APP)_opted.riscv
	$(SIM) $<

simoptv: $(APP)_opted.riscv
	$(SIM) +verbose $< $(VERBOSE_TO_FILE)
	# written to simoptv.stdout, simoptv.log instead

# ---------------------------------------------------

# this is used to extract cycle records not in Debug Mode (those pc not in the objdump file) 
#	and Infinite Loop (the "c.j pc + 0" for waiting till simulation be terminated)
# 	thank Stefan for writing this command for me 
strip: $(APP).riscv.dump simv.log
	awk 'NF>2 && NR>5 { split($1, subfield, ":"); print "00"subfield[1] }' $(APP).riscv.dump > pc_list.tmp
	awk -F "[][]" 'NR == FNR { a[$0]; next } {if(($4 in a) && ($14!="0000a001")) print $0}' pc_list.tmp simv.log > strip_simv.log
	rm pc_list.tmp