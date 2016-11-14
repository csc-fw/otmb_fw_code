set shortname  "otmb_virtex6"
set top_name   "otmb_virtex6"
set myProject  "otmb_virtex6"
set prom_type  "XCF128X"
set work_dir   "work"
set source_dir "source"

set myScript   "genproms.tcl"

set folder [lindex [split [pwd] /] end]
if { $folder != "tools" } {
    puts "This script needs to be executed from tools directory"
    return
} else {
    cd ../
}

set bit_filename   ${work_dir}/${top_name}.bit
set mcs_filename   ${work_dir}/${top_name}.mcs
set cfi_filename   ${work_dir}/${top_name}.cfi
set prm_filename   ${work_dir}/${top_name}.prm
set svf_verify     ${work_dir}/${top_name}_verify.svf
set svf_noverify   ${work_dir}/${top_name}_noverify.svf
set impact_script  ${work_dir}/${top_name}.impactscript
set version_file   ${source_dir}/otmb_virtex6_fw_version.v

set project_dir    [pwd]/${work_dir}

# optohybrid version extracting
set filename ${version_file}
set version_pattern {reg_data\(0\)}

set type  "0"
set month "00"
set day   "00"
set year  "0000"
set revision "01"

set fid [open $filename r]
while {[gets $fid line] != -1} {

    # type
    if { [ regexp -all -- FIRMWARE_TYPE $line] } {
        regexp {[0-9]{2}\'[A-z]{2}} $line matched
        set  type  [string range ${matched} 4 4]
    }

    # monthday
    if { [ regexp -all -- MONTHDAY $line] } {
        regexp {h[0-9]{4}} $line matched
        set  month  [string range ${matched} 1 2]
        set  day  [string range ${matched} 3 4]
    }

    # year
    if { [ regexp -all -- YEAR $line] } {
        regexp {h[0-9]{4}} $line matched
        set  year  [string range ${matched} 1 4]
    }

    # revision
    if { [ regexp -all -- REVISION $line] } {
        regexp {h[0-9]{2}} $line matched
        set  revision  [string range ${matched} 1 2]
    }


}
close $fid

set datecode ${year}-${month}-${day}

set fullname "${shortname}_${type}_${datecode}_v${revision}"

puts "Generating PROM files for firmware version ${fullname}"

## put out a 'heartbeat' - so we know something's happening.
puts "\n$myScript: running ($myProject)...\n"

################################################################################
puts "Generating mcs file..."
################################################################################

if {[catch {set f_id [open $impact_script w]} msg]} {
    puts "Can't create $impact_script"
    puts $msg
    return
}

puts "Opened impact script for writing..."

puts $f_id "setMode -pff"
puts $f_id "setMode -pff"

puts $f_id "addConfigDevice  -name \"${top_name}\" -path \"$project_dir\""
puts $f_id "setSubmode -pffbpi"
puts $f_id "setAttribute -configdevice -attr multibootBpiType -value \"TYPE_BPI\""
puts $f_id "setAttribute -configdevice -attr multibootBpiDevice -value \"VIRTEX6\""
puts $f_id "setAttribute -configdevice -attr multibootBpichainType -value \"PARALLEL\""
puts $f_id "addDesign -version 0 -name \"0\""
puts $f_id "setMode -pff"
puts $f_id "addDeviceChain -index 0"
puts $f_id "setMode -pff"
puts $f_id "addDeviceChain -index 0"
puts $f_id "setAttribute -configdevice -attr compressed -value \"FALSE\""
puts $f_id "setAttribute -configdevice -attr compressed -value \"FALSE\""
puts $f_id "setAttribute -configdevice -attr autoSize -value \"FALSE\""
puts $f_id "setAttribute -configdevice -attr fileFormat -value \"mcs\""
puts $f_id "setAttribute -configdevice -attr fillValue -value \"FF\""
puts $f_id "setAttribute -configdevice -attr swapBit -value \"FALSE\""
puts $f_id "setAttribute -configdevice -attr dir -value \"UP\""
puts $f_id "setAttribute -configdevice -attr multiboot -value \"FALSE\""
puts $f_id "setAttribute -configdevice -attr multiboot -value \"FALSE\""
puts $f_id "setAttribute -configdevice -attr spiSelected -value \"FALSE\""
puts $f_id "setAttribute -configdevice -attr spiSelected -value \"FALSE\""
puts $f_id "setAttribute -configdevice -attr ironhorsename -value \"1\""
puts $f_id "setAttribute -configdevice -attr flashDataWidth -value \"16\""
puts $f_id "setCurrentDesign -version 0"
puts $f_id "setAttribute -design -attr RSPin -value \"\""
puts $f_id "setCurrentDesign -version 0"
puts $f_id "addPromDevice -p 1 -size 131072 -name 128M"
puts $f_id "setMode -pff"
puts $f_id "setMode -pff"
puts $f_id "setMode -pff"
puts $f_id "setMode -pff"
puts $f_id "addDeviceChain -index 0"
puts $f_id "setMode -pff"
puts $f_id "addDeviceChain -index 0"
puts $f_id "setMode -pff"
puts $f_id "setSubmode -pffbpi"
puts $f_id "setMode -pff"

puts $f_id "setAttribute -design -attr RSPin -value \"00\""
puts $f_id "addDevice -p 1 -file \"${bit_filename}\""
puts $f_id "setAttribute -design -attr RSPinMsb -value \"1\""
puts $f_id "setAttribute -design -attr name -value \"0\""
puts $f_id "setAttribute -design -attr RSPin -value \"00\""
puts $f_id "setAttribute -design -attr endAddress -value \"53638b\""
puts $f_id "setAttribute -design -attr endAddress -value \"53638b\""
puts $f_id "setMode -pff"
puts $f_id "setSubmode -pffbpi"
puts $f_id "generate"

################################################################################
# Build SVF Files
################################################################################


puts $f_id "setCurrentDesign -version 0"
puts $f_id "setMode -bs"
puts $f_id "setMode -bs"
puts $f_id "setMode -bs"
puts $f_id "setMode -bs"

puts $f_id "setCable -port svf -file \"${svf_verify}\""
puts $f_id "addDevice -p 1 -file \"$bit_filename\""
puts $f_id "attachflash -position 1 -bpi $prom_type"
puts $f_id "assignfiletoattachedflash -position 1 -file \"$mcs_filename\""

puts $f_id "Program -p 1 -dataWidth 16 -rs1 NONE -rs0 NONE -bpionly -e -v -loadfpga "

puts $f_id "setCable -port svf -file \"$svf_noverify\""
puts $f_id "Program -p 1 -bpionly -e -loadfpga "

################################################################################
puts $f_id "quit"
################################################################################

close $f_id

puts "Finished writing impact script..."

set impact_p [open "|impact -batch $impact_script" r]
#puts [exec impact -batch "${impact_script}"]


# echo impact output here: 
while {![eof $impact_p]} { gets $impact_p line ; puts $line }

puts "Finished Creating PROM Files" 

# adapted from https://forums.xilinx.com/t5/Vivado-TCL-Community/Vivado-TCL-set-generics-based-on-date-git-hash/td-p/426838

# Current date, time, and seconds since epoch
# 0 = 4-digit year
# 1 = 2-digit year
# 2 = 2-digit month
# 3 = 2-digit day
# 4 = 2-digit hour
# 5 = 2-digit minute
# 6 = 2-digit second
# 7 = Epoch (seconds since 1970-01-01_00:00:00)
# Array index                                            0  1  2  3  4  5  6  7
#set datetime_arr [clock format [clock seconds] -format {%Y %y %m %d %H %M %S %s}]

# Get the datecode in the yyyy-mm-dd format
#set datecode [lindex $datetime_arr 0]-[lindex $datetime_arr 2]-[lindex $datetime_arr 3]

# Show this in the log
#puts DATECODE=$datecode

# Get the git hashtag for this project
#set curr_dir [pwd]
#set proj_dir [get_property DIRECTORY [current_project]]
#cd $proj_dir
#set git_hash [exec git log -1 --pretty='%h']
# Show this in the log
#puts HASHCODE=$git_hash

# Set the generics
#set_property generic "DATE_CODE=32'h$datecode HASH_CODE=32'h$git_hash" [current_fileset]


set releasedir     release/${datecode}_v${revision}

if {![file isdirectory release]} {
    file mkdir release
}

if {![file isdirectory $releasedir]} {
    file mkdir $releasedir
}


file copy -force $mcs_filename   ${releasedir}/${fullname}.mcs
file copy -force $bit_filename   ${releasedir}/${fullname}.bit
#file copy -force $svf_verify     ${releasedir}/${fullname}_verify.svf
#file copy -force $svf_noverify   ${releasedir}/${fullname}_noverify.svf
file copy -force $prm_filename   ${releasedir}/${fullname}.prm
file copy -force $cfi_filename   ${releasedir}/${fullname}.cfi
