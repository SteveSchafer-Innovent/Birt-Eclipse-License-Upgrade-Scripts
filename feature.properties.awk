BEGIN {
    c=0; # Not a line continuation.
    lineCount=0;
}
(NR==FNR) {
    # print "** adding line **";
    lines[lineCount++]=$0;
    next;
}
/^license=.*\\$/ {
    # print "** first line found **";
    c=1;
    next;
}
/\\$/ && (c==1) { # Line continuation.  Accumulate the value.
    # print "** continuation line found **";
    c=1;
    next;
}
(c==1) && !/\\$/ { # End of line continuation
    # print "** end of license found **";
    for(i=0; i<lineCount; i++) {
        print lines[i];
    }
    c=0;
    next;
}
/.*/ {
    print $0;
}
END {
}
