BEGIN {
    c=0; # Not a line continuation.
    lineCount=0;
}
(NR==FNR) {
    # print "** adding line **";
    lines[lineCount++]=$0;
    next;
}
/^[ ]*<h3>License<\/h3>[ ]*$/ {
    # print "** first line found **";
    c=1;
    next;
}
(c==1) && (/^[ ]*<h[0-9]>/ || /^[ ]*<\/body>/) { # End of license
    for(i=0; i<lineCount; i++) {
        print lines[i];
    }
    print $0
    c=0;
    next;
}
(c==0) {
    print $0;
}
END {
    if(c==1) {
        print "** end of license not found **";
    }
}
