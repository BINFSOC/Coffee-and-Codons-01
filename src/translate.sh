#! /usr/bin/env bash

# Coffee+Codons 01 
# Simple program written for BINFSOC
# (UNSW Bioinformatics Society) 
# by Cam McMenamie 

# Translate DNA sequence to AA (protein)
# TODO:
# - handle frameshift
# - handle invalid input 
# - translate to RNA 
# - support for more codon tables 
# --------------------------------------


# Delim character used for partitioning codons
delim='\n'
CODON_LENGTH=3

# Remove newlines
tr -d '\n' |

# Convert to uppercase
tr '[:lower:]' '[:upper:]' |

# Separate by codon
sed "s/.\{$CODON_LENGTH\}/&$delim/g" |

# Translate to AA
sed -f codon.sed |

# Remove delim character 
tr -d "$delim"

# Output newline character
echo -e
