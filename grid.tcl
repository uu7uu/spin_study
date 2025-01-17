proc grid_generate {filename args} {
    global mass incl dist  ;# 将它们声明为全局变量
    set fileId [open $filename r]
    set lines [list]

    while {[gets $fileId line] >= 0} {
        lappend lines $line
    }
    close $fileId

    for {set i 0} {$i < [llength $lines]} {incr i} {
        set values [lindex $lines $i]
        set value [split $values " "]
        set mass [lindex $value 0]
        set incl [lindex $value 1]
        set dist [lindex $value 2]
        puts $mass
        use_spec

    }
}

proc fit_process {baseName} {
    global mass incl dist  ;# 访问全局变量
    newp 49 $incl -1
    newp 50 $mass -1
    newp 52 $dist -1
    newp 51 0.1
    fit
    cchi
    global cchi
    if { $cchi > 2 } {
        save_results $baseName
    } else {
        cat_err
        save_results $baseName
    }
}

proc save_results {baseName} {
    global mass incl dist Ledd
    set txtname "grid_result.txt"
    write_result $txtname ${baseName}_${mass}_${incl}_${dist}_${Ledd}
}

proc use_spec {args} {
    global mass incl dist Ledd
    set filenames {"_ni6756010104_night_kerrbb.xcm" "_ni6756010106_night_kerrbb.xcm" "_ni6756010108_night_kerrbb.xcm" "_ni6756010109_night_kerrbb.xcm" "_ni6756010110_night_kerrbb.xcm" "_ni7661010105_night_kerrbb.xcm" "_ni7661010109_night_kerrbb.xcm" "_ni7661010111_night_kerrbb.xcm" "_ni7661010116_night_kerrbb.xcm" "_ni7661010117_night_kerrbb.xcm" "_ni7661010118_night_kerrbb.xcm"}
    set flux {3.360240167e-08 3.156320713e-08 2.360325981e-08 2.212969098e-08 2.153668993e-08 9.91562649e-09 6.963826495e-09 4.099713183e-09 2.368889349e-09 2.26807674e-09 2.392609541e-09}
    foreach filename $filenames flux_val $flux {
        # 计算k, l, L 和 Ledd
        set k [expr {4 * 3.14159265359 * ($dist * 3.08567758e21) ** 2}]
        set l [expr {$mass * 1.3e38}]
        set L [expr {$flux_val * $k}]
        set Ledd [expr {100 * $L / $l}]
        
        # 判断是否符合条件
        if { $Ledd <= 30 && $Ledd >= 3 } {
            puts "Ledd= $Ledd ，符合条件，处理文件: ${filename}_${mass}_${incl}_${dist}"
            @${filename}
            fit_process $filename
        } else {
            puts "Ledd= $Ledd ，不符合条件，跳过文件: ${filename}_${mass}_${incl}_${dist}"
        }
    }
}
