BEGIN {
	c=0; # Not a line continuation.
	lineCount=0;
}
(NR==FNR) {
	# print "** adding line **";
	lines[lineCount++]=$0;
	next;
}
(c==0) && /^ \* Copyright \(c\) [0-9, ]+Actuate Corporation\./ {
	# print "** first line found **";
	print $0
	print " *"
	c=1;
	next;
}
(c==1) && /^ \* Contributors:/ { # End of license
	for(i=0; i<lineCount; i++) {
		print " * " lines[i];
	}
	print $0
	c=2;
	next;
}
(c==2) && (/^ \*\*\*\*+/ || /^ \*[ ]*$/) {
	print $0;
	c=0;
	next
}
(c==2) {
	print $0;
}
(c==0) {
	print $0;
}
END {
	if(c==1) {
		print "** Copyright line not found **" > "/dev/stderr";
		exit 1;
	}
	else if(c==2) {
		print "** Contributors line not found **" > "/dev/stderr";
		exit 1;
	}
}
