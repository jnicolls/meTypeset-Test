#!/bin/bash

rm -rf /var/local/meTypesetTests/tests/testOutput
rm -rf /var/local/meTypesetTests/tests/error
mkdir  /var/local/meTypesetTests/tests/error
mkdir  /var/local/meTypesetTests/tests/testOutput
cd /var/local/meTypesetTests/testingDocuments/OpenMedDocx
for f in *; do 
	returnval= $0
	returnval= timeout 5m  python /var/www/public/parsingdev/meTypeset/bin/meTypeset.py docx "$f" /var/local/meTypesetTests/tests/testOutput/"$f" -d --nogit
	if [ "$returnval" = "124" ]; then
		rm -rf /var/local/meTypesetTests/tests/testOutput	
	fi
done
cd /var/local/meTypesetTests/tests/testOutput
for dir in *; do 
	returnval= $0
	returnval= timeout --signal=SIGQUIT  5m xmllint --dtdvalid http://jats.nlm.nih.gov/archiving/1.1d3/JATS-archivearticle1.dtd "$dir"/nlm/out.xml 2> /var/local/meTypesetTests/tests/error/"$dir" 
	if [ "$returnval" = "124" -a -a /var/local/meTypesetTests/tests/error/"$dir" ]; then
		printf 'timeout has occured during xmllint' >> /var/local/meTypesetTests/tests/error/"$dir"
	fi
done
cd /var/local/meTypesetTests/tests
pybot testForSuccessfulConversion.txt
yes | cp -i		log.html          /var/www/public/parsingdev/robot/Corpus
yes | cp -i 		output.xml       /var/www/public/parsingdev/robot/Corpus
yes | cp -i 		report.html		/var/www/public/parsingdev/robot/Corpus
