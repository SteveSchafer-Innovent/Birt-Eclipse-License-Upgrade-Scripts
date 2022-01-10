BEGIN {
    print "** filetype " filetype " **" > "/dev/stderr";
    print "** noDefault " noDefault " **" > "/dev/stderr";
    commentLineCount=0; # Existing copyright comment
    newLineCount=0; # New copyright comment
    copyrightFound=0;
    copyrightYears="";
    licenseFound=0;
    contributorsFound=0;
    startLineNumber=1;
    defaultCopyrightInserted=0;
    if(filetype=="java") {
        firstLineRegex="^/\\*\\*\\*+";
        copyrightLineRegex="^ *\\* Copyright \\([cC]\\) *[0-9]+";
        contributorsLineRegex="^ \\* Contributors:";
        licenseRegex="^ \\* All rights reserved";
        subsequentLineRegex="^ \\* ";
        lastLineRegex="^ *\\*\\*\\*+";
        firstLine="/*******************************************************************************";
        lastLine=" *******************************************************************************/";
        prefix=" * ";
    }
    else if(filetype=="properties") {
        firstLineRegex="^#/\\*\\*\\*+";
        copyrightLineRegex="^# \\* Copyright \\([cC]\\) [0-9]+";
        contributorsLineRegex="^# \\* Contributors:";
        licenseRegex="^# \\* All rights reserved";
        subsequentLineRegex="^# \\* ";
        lastLineRegex="^# *\\*\\*\\*+";
        firstLine="#/*******************************************************************************";
        lastLine="# *******************************************************************************/";
        prefix="# * ";
    }
    else if(filetype=="xml") {
        firstLineRegex="^<!--";
        copyrightLineRegex="^ \\* Copyright \\([cC]\\) [0-9]+";
        contributorsLineRegex="^ \\* Contributors:";
        licenseRegex="^ \\* All rights reserved";
        subsequentLineRegex="^ \\* ";
        lastLineRegex="^ *\\*\\*\\*+";
        firstLine="<!--\n *******************************************************************************";
        lastLine=" *******************************************************************************\n-->";
        prefix=" * ";
    }
    else if(filetype=="msg") {
        firstLineRegex="^#+";
        copyrightLineRegex="^# Copyright \\([cC]\\) [0-9]+";
        contributorsLineRegex="^# Contributors:";
        licenseRegex="^# All rights reserved";
        subsequentLineRegex="^# ";
        lastLineRegex="^#+";
        firstLine="###############################################################################";
        lastLine="###############################################################################";
        prefix="# ";
    }
}
NR==FNR {
    # print "** adding line **";
    lines[newLineCount++]=$0;
    next;
}
FNR==1 {
    print FILENAME > "/dev/stderr";
}
filetype=="xml" && FNR==startLineNumber && /^<\?/ {
    # first line of xml
    print "** found xml <? > line **" > "/dev/stderr";
    print $0;
    startLineNumber=startLineNumber+1;
    next;
}
filetype=="java" && FNR==2 && 
    match($0, /^ \* Copyright \([cC]\) ([0-9, ]+) ([A-Za-z. ]+) All rights reserved\./, a) {
    copyrightYears=a[1];
    copyrightHolder=a[2];
    print "**** nonstandard copyright comment found: " copyrightYears > "/dev/stderr";
    print " * Copyright (c) " copyrightYears " " copyrightHolder;
    print " *";
    # insert new license
    for(i=0; i<newLineCount; i++) {
        line=lines[i];
        print prefix line;
    }
    licenseFound=1;
    copyrightFound=1;
    commentLineCount=commentLineCount+1;
    next;
}
$0 ~ firstLineRegex && FNR==startLineNumber {
    if(filetype == "xml" && $0 ~ /^<!--.*-->/) {
        # single line comment terminates xml search
    }
    else {
        # first line of copyright comment
        print "** found first line **" > "/dev/stderr";
        print $0;
        commentLineCount=1;
        next;
    }
}
FNR==startLineNumber && noDefault==0 {
    # comment not found
    # insert new comment
    print "** comment not found. inserting new comment **" > "/dev/stderr";
    print firstLine;
    print prefix "Copyright (c) 2021 Contributors to the Eclipse Foundation"
    print prefix ""
    for(i=0; i<newLineCount; i++) {
        line=lines[i];
        print prefix line;
    }
    print prefix "Contributors:"
    print prefix "  See git history"
    print lastLine;
    print $0;
    commentLineCount=0;
    copyrightFound=1;
    defaultCopyrightInserted=1;
    next;
}
$0 ~ copyrightLineRegex {
    if(defaultCopyrightInserted==1) {
        print "** ERROR: duplicate copyright **" > "/dev/stderr";
        exit 2;
    }
    print "** found copyright ** " > "/dev/stderr";
    print $0;
    copyrightFound=1;
    commentLineCount=commentLineCount+1;
    next;
}
$0 ~ contributorsLineRegex {
    # contributors line found
    print "** found contributors line **" > "/dev/stderr";
    print $0;
    contributorsFound=1;
    commentLineCount=commentLineCount+1;
    next;
}
$0 ~ licenseRegex {
    # license found
    # insert new license
    print "** found license line **" > "/dev/stderr";
    print prefix "";
    for(i=0; i<newLineCount; i++) {
        line=lines[i];
        print prefix line;
    }
    licenseFound=1;
    copyrightFound=1;
    commentLineCount=commentLineCount+1;
    next;
}
$0 ~ subsequentLineRegex && commentLineCount>0 {
    # subsequent line of copyright comment
    # print "** found subsequent line **";
    print "** found subsequent line **" > "/dev/stderr";
    if (contributorsFound==1 || licenseFound==0) {
        print $0;
    }
    commentLineCount=commentLineCount+1;
    next;
}
$0 ~ lastLineRegex && commentLineCount>0 {
    # last line of copyright comment
    # print "** found last line **";
    print "** found last line **" > "/dev/stderr";
    print $0;
    commentLineCount=0;
    # in case of multiple license comments
    contributorsFound=0;
    next;
}
commentLineCount>0 {
    print "** found non-comment line before last comment line **" > "/dev/stderr";
    print $0;
    commentLineCount=0;
    next;
}
commentLineCount==0 {
    print $0;
    next;
}
END {
    if(commentLineCount>0) {
        print "** ERROR: end of comment not found **" > "/dev/stderr";
        exit 1;
    }
    if(copyrightFound==0) {
        print "** ERROR: copyright not found **" > "/dev/stderr";
        exit 1;
    }
}
