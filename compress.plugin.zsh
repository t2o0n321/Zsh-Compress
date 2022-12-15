help(){
	echo "- Usage: zcompress [targetFile] [outFile]"
}

getExt(){
	local outFilePath=$1
	local ext=$(echo $outFilePath | rev | cut -d "/" -f 1 | cut -d "." -f 1 | rev)
	echo $ext
}

checkCommand(){
	local toCheck=$1
	if ! command -v $toCheck &> /dev/null
	then
		echo 0
	else
		echo 1
	fi
}

alias zc=zcompress

zcompress(){
	# Pending Input
	if ! [ "$#" -ge 2 ]; then
		echo "Syntax error"
		help
	else
		local targetFolder=$1
		local outFilePath=$2
		local ext=$(getExt $outFilePath)

		case "${outFilePath:l}" in
			(*.rar)
				if [ $(checkCommand rar) -eq "0" ]; then
					echo "Installing rar ... "
					sudo apt install rar -y
				fi
				rar a $outFilePath $targetFolder
				;;
			(*.zip)
				if [ $(checkCommand zip) -eq "0" ]; then
					echo "Installing zip ... "
					sudo apt install zip -y
				fi
				zip -r $outFilePath $targetFolder
				;;
			(*.7z)
				if [ $(checkCommand 7z) -eq "0" ]; then
					echo "Installing 7z ... "
					sudo apt install p7zip-full -y
				fi
				7z a $outFilePath $targetFolder
				;;
			(*.bz2)
				if [ $(checkCommand tar) -eq "0" ]; then
					echo "Installing tar ... "
					sudo apt install tar -y
				fi
				if [ $(checkCommand bzip2) -eq "0" ]; then
					echo "Installing tar ... "
					sudo apt install bzip2 -y
				fi
				tar -cf "${outFilePath}.tar" $targetFolder && bzip2 "${outFilePath}.tar" && mv "${outFilePath}.tar.bz2" $outFilePath
				;;
			(*.tar)
				if [ $(checkCommand tar) -eq "0" ]; then
					echo "Installing tar ... "
					sudo apt install tar -y
				fi
				tar cvf $outFilePath $targetFolder
				;;
			(*.tar.xz)
				if [ $(checkCommand tar) -eq "0" ]; then
					echo "Installing tar ... "
					sudo apt install tar -y
				fi
				tar Jcvf $outFilePath $targetFolder
				;;
			(*.tar.gz | *.tgz)
				if [ $(checkCommand tar) -eq "0" ]; then
					echo "Installing tar ... "
					sudo apt install tar -y
				fi
				tar zcvf $outFilePath $targetFolder
				;;
			(*)
				echo "Fail to compress to $outFilePath ... "
				echo "Extension '$ext' is not supported ... "
				;;
		esac

	fi
}
