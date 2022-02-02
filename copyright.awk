BEGIN {
    print "** new file **" > "/dev/stderr";
    print "** filetype " filetype " **" > "/dev/stderr";
    print "** noDefault " noDefault " **" > "/dev/stderr";
    print "** addDefault " addDefault " **" > "/dev/stderr";
    commentLineCount=0; # Existing copyright comment
    newLineCount=0; # New copyright comment
    copyrightFound=0;
    copyrightYears="";
    licenseFound=0;
    contributorsFound=0;
    startLineNumber=1;
    defaultCopyrightInserted=0;
    altCount = 1;
    altFound = 0;
    if(filetype=="java") {
        altCount = 3;
        altFound = 0;
        firstLineRegex[altFound]="^/\\*\\*\\*+";
        copyrightLineRegex[altFound]="^ *\\* Copyright \\([cC]\\) *[0-9]+";
        contributorsLineRegex[altFound]="^ \\* Contributors:";
        licenseRegex[altFound]="^ \\* All rights reserved";
        subsequentLineRegex[altFound]="^ \\* ";
        lastLineRegex[altFound]="^ *\\*\\*\\*+";
        firstLine[altFound]="/*******************************************************************************";
        lastLine[altFound]=" *******************************************************************************/";
        prefix[altFound]=" * ";
        altFound = 1;
        firstLineRegex[altFound]="^///\\*\\*\\*+";
        copyrightLineRegex[altFound]="^// *\\* Copyright \\([cC]\\) *[0-9]+";
        contributorsLineRegex[altFound]="^// \\* Contributors:";
        licenseRegex[altFound]="^// \\* All rights reserved";
        subsequentLineRegex[altFound]="^// \\* ";
        lastLineRegex[altFound]="^// *\\*\\*\\*+";
        firstLine[altFound]="///*******************************************************************************";
        lastLine[altFound]="// *******************************************************************************/";
        prefix[altFound]="// * ";
        altFound = 2;
        firstLineRegex[altFound]="^/\\* +Copyright \\([cC]\\) *[0-9]+";
        copyrightLineRegex[altFound]="";
        contributorsLineRegex[altFound]="^ \\* Contributors:";
        licenseRegex[altFound]="^ \\* All rights reserved";
        subsequentLineRegex[altFound]="^ \\* ";
        lastLineRegex[altFound]="^ *\\*\\*\\*+";
        firstLine[altFound]="/*******************************************************************************";
        lastLine[altFound]=" *******************************************************************************/";
        prefix[altFound]=" * ";
    }
    else if(filetype=="properties") {
        altCount = 3;
        altFound = 0;
        firstLineRegex[altFound]="^#/\\*\\*\\*+";
        copyrightLineRegex[altFound]="^# \\* Copyright \\([cC]\\) [0-9]+";
        contributorsLineRegex[altFound]="^# \\* Contributors:";
        licenseRegex[altFound]="^# \\* All rights reserved";
        subsequentLineRegex[altFound]="^# \\* ";
        lastLineRegex[altFound]="^# *\\*\\*\\*+";
        firstLine[altFound]="#/*******************************************************************************";
        lastLine[altFound]="# *******************************************************************************/";
        prefix[altFound]="# * ";
        altFound = 1;
        firstLineRegex[altFound]="^##+";
        copyrightLineRegex[altFound]="^# Copyright \\([cC]\\) [0-9]+";
        contributorsLineRegex[altFound]="^# Contributors:";
        licenseRegex[altFound]="^# All rights reserved";
        subsequentLineRegex[altFound]="^# ";
        lastLineRegex[altFound]="^##+";
        firstLine[altFound]="###############################################################################";
        lastLine[altFound]="###############################################################################";
        prefix[altFound]="# ";
        altFound = 2;
        firstLineRegex[altFound]="^#\\**";
        copyrightLineRegex[altFound]="^# Copyright \\([cC]\\) [0-9]+";
        contributorsLineRegex[altFound]="^# Contributors:";
        licenseRegex[altFound]="^# All rights reserved";
        subsequentLineRegex[altFound]="^#";
        lastLineRegex[altFound]="^#\\*\\*\\*+";
        firstLine[altFound]="#/*******************************************************************************";
        lastLine[altFound]="# *******************************************************************************/";
        prefix[altFound]="# * ";
    }
    else if(filetype=="xml") {
        firstLineRegex[altFound]="^<!--";
        copyrightLineRegex[altFound]="^ \\* Copyright \\([cC]\\) [0-9]+";
        contributorsLineRegex[altFound]="^ \\* Contributors:";
        licenseRegex[altFound]="^ \\* All rights reserved";
        subsequentLineRegex[altFound]="^ \\* ";
        lastLineRegex[altFound]="^ *\\*\\*\\*+";
        firstLine[altFound]="<!--\n *******************************************************************************";
        lastLine[altFound]=" *******************************************************************************\n-->";
        prefix[altFound]=" * ";
    }
    else if(filetype=="msg") {
        firstLineRegex[altFound]="^#+";
        copyrightLineRegex[altFound]="^# Copyright \\([cC]\\) [0-9]+";
        contributorsLineRegex[altFound]="^# Contributors:";
        licenseRegex[altFound]="^# All rights reserved";
        subsequentLineRegex[altFound]="^# ";
        lastLineRegex[altFound]="^#+";
        firstLine[altFound]="###############################################################################";
        lastLine[altFound]="###############################################################################";
        prefix[altFound]="# ";
    }
    altFound = 0;
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
        print prefix[0] line;
    }
    licenseFound = 1;
    copyrightFound = 1;
    commentLineCount = commentLineCount + 1;
    next;
}
FNR == startLineNumber && addDefault == 1 {
    # insert new comment
    print "** inserting new comment **" > "/dev/stderr";
    print firstLine[altFound];
    print prefix[altFound] "Copyright (c) 2021 Contributors to the Eclipse Foundation"
    print prefix[altFound] ""
    for(i=0; i<newLineCount; i++) {
        line=lines[i];
        print prefix[altFound] line;
    }
    print prefix[altFound] "Contributors:"
    print prefix[altFound] "  See git history"
    print lastLine[altFound];
    print $0;
    commentLineCount=0;
    copyrightFound=1;
    defaultCopyrightInserted=1;
    next;
}
FNR == startLineNumber {
    altFound = 0;
    for(i = 0; i < altCount; i++) {
        if($0 ~ firstLineRegex[i]) {
            altFound = i;
            if(filetype == "xml" && $0 ~ /^<!--.*-->/) {
                # single line comment terminates xml search
            }
            else {
                # first line of copyright comment
                print "** found first line alt " i " **" > "/dev/stderr";
                print $0;
                commentLineCount = 1;
                if(copyrightLineRegex[altFound] == "") {
                    copyrightFound = 1;
                }
                next;
            }
        }
    }
}
FNR == startLineNumber && noDefault == 0 {
    # comment not found
    # insert new comment
    print "** comment not found. inserting new comment **" > "/dev/stderr";
    print firstLine[altFound];
    print prefix[altFound] "Copyright (c) 2021 Contributors to the Eclipse Foundation"
    print prefix[altFound] ""
    for(i=0; i<newLineCount; i++) {
        line=lines[i];
        print prefix[altFound] line;
    }
    print prefix[altFound] "Contributors:"
    print prefix[altFound] "  See git history"
    print lastLine[altFound];
    print $0;
    commentLineCount=0;
    copyrightFound=1;
    defaultCopyrightInserted=1;
    next;
}
copyrightLineRegex[altFound] != "" && $0 ~ copyrightLineRegex[altFound] {
    if(defaultCopyrightInserted==1) {
        print "** duplicate copyright. will run again without default **" > "/dev/stderr";
        exit 2;
    }
    print "** found copyright ** " > "/dev/stderr";
    print $0;
    copyrightFound=1;
    commentLineCount=commentLineCount+1;
    next;
}
$0 ~ contributorsLineRegex[altFound] {
    # contributors line found
    print "** found contributors line **" > "/dev/stderr";
    print $0;
    contributorsFound=1;
    commentLineCount=commentLineCount+1;
    next;
}
$0 ~ licenseRegex[altFound] {
    # license found
    # insert new license
    print "** found license line **" > "/dev/stderr";
    print prefix[altFound] "";
    for(i=0; i<newLineCount; i++) {
        line=lines[i];
        print prefix[altFound] line;
    }
    licenseFound=1;
    copyrightFound=1;
    commentLineCount=commentLineCount+1;
    next;
}
$0 ~ subsequentLineRegex[altFound] && commentLineCount>0 {
    # subsequent line of copyright comment
    # print "** found subsequent line **";
    print "** found subsequent line **" > "/dev/stderr";
    if (contributorsFound==1 || licenseFound==0) {
        print $0;
    }
    commentLineCount=commentLineCount+1;
    next;
}
$0 ~ lastLineRegex[altFound] && commentLineCount>0 {
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
        print "** copyright not found. will run again and force default copyright **" > "/dev/stderr";
        exit 3;
    }
}
