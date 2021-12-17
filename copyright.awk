BEGIN {
    oldLineCount=0; # Existing copyright comment
    newLineCount=0; # New copyright comment
    copyrightFound=0;
    licenseFound=0;
    contributorsFound=0;
    startLineNumber=1;
    if(filetype=="java") {
        firstLineRegex="^/\\*+";
        copyrightLineRegex="^ \\* Copyright \\(c\\)";
        contributorsLineRegex="^ \\* Contributors:";
        licenseRegex="^ \\* All rights reserved";
        subsequentLineRegex="^ \\* ";
        lastLineRegex="^ \\*+/";
        firstLine="/*******************************************************************************";
        lastLine=" *******************************************************************************/";
        prefix=" * ";
    }
    else if(filetype=="properties") {
        firstLineRegex="^#/\\*+";
        copyrightLineRegex="^# \\* Copyright \\(c\\)";
        contributorsLineRegex="^# \\* Contributors:";
        licenseRegex="^# \\* All rights reserved";
        subsequentLineRegex="^# \\* ";
        lastLineRegex="^# \\*+/";
        firstLine="#/*******************************************************************************";
        lastLine="# *******************************************************************************/";
        prefix="# * ";
    }
    else if(filetype=="xml") {
        firstLineRegex="^<!--";
        copyrightLineRegex="^ \\* Copyright \\(c\\)";
        contributorsLineRegex="^ \\* Contributors:";
        licenseRegex="^ \\* All rights reserved";
        subsequentLineRegex="^ \\* ";
        lastLineRegex="^ \\*+";
        firstLine="<!--\n *******************************************************************************";
        lastLine=" *******************************************************************************\n-->";
        prefix=" * ";
    }
    else if(filetype=="msg") {
        firstLineRegex="^#+";
        copyrightLineRegex="^# Copyright \\(c\\)";
        contributorsLineRegex="^# Contributors:";
        licenseRegex="^# All rights reserved";
        subsequentLineRegex="^# ";
        lastLineRegex="^#+";
        firstLine="###############################################################################";
        lastLine="###############################################################################";
        prefix="# ";
    }
}
(NR==FNR) {
    # print "** adding line **";
    lines[newLineCount++]=$0;
    next;
}
(filetype=="xml") && (FNR==startLineNumber) && /^<\?/ {
    # first line of xml
    print $0
    startLineNumber=startLineNumber+1;
    next;
}
($0 ~ firstLineRegex) && (FNR==startLineNumber) {
    # first line of copyright comment
    # print "** found first line **";
    print $0;
    oldLineCount=1;
    next;
}
(FNR==startLineNumber) {
    # comment not found
    # insert new comment
    print firstLine;
    print prefix "Copyright (c) 2021 Contributors to Eclipse Foundation"
    print prefix ""
    for(i=0; i<newLineCount; i++) {
        line=lines[i];
        print prefix line;
    }
    print prefix "Contributors:"
    print prefix "  See git history"
    print lastLine;
    print $0
    oldLineCount=0;
    next;
}
($0 ~ copyrightLineRegex) && (oldLineCount>=1) {
    # copyright found
    print $0;
    print prefix "All rights reserved.";
    print prefix "";
    copyrightFound=1;
    oldLineCount=oldLineCount+1;
    next;
}
($0 ~ contributorsLineRegex) && (oldLineCount>1) {
    # contributors line found
    print $0;
    contributorsFound=1;
    oldLineCount=oldLineCount+1;
    next;
}
($0 ~ licenseRegex) && (oldLineCount>1) {
    # license found
    # insert new license
    for(i=0; i<newLineCount; i++) {
        line=lines[i];
        print prefix line;
    }
    licenseFound=1;
    oldLineCount=oldLineCount+1;
    next;
}
($0 ~ subsequentLineRegex) && (oldLineCount>=1) {
    # subsequent line of copyright comment
    # print "** found subsequent line **";
    if (contributorsFound==1 || licenseFound==0) {
        print $0;
    }
    oldLineCount=oldLineCount+1;
    next;
}
($0 ~ lastLineRegex) && (oldLineCount>=2) {
    # last line of copyright comment
    # print "** found last line **";
    print prefix " Others: See git history";
    print $0;
    oldLineCount=0;
    next;
}
(oldLineCount==0) {
    print $0;
}
END {
    if(oldLineCount>0) {
        print "// ** end of copyright not found **";
    }
    if(copyrightFound==0) {
        # print "** copyright not found **";
    }
}
