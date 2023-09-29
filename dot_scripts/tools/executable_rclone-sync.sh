#!/usr/bin/bash

if [[ $SHLVL -lt 4 ]]; then
	exec > >(tee -a /home/alan/.rclone.log) 2>&1

	rclone bisync /mnt/DiscoExterno/Users/Alan/Documents/_Arquivos/PDFs gdrive:RClone/PDFs --verbose --check-access
	rclone bisync /mnt/DiscoExterno/Users/Alan/Documents/_Arquivos/Office gdrive:RClone/Office --verbose --check-access

	rclone bisync /mnt/DiscoExterno/Users/Alan/Documents/_Codes/Markdown/USP gdrive:RClone/USP --verbose --check-access
else
	rclone bisync /mnt/DiscoExterno/Users/Alan/Documents/_Arquivos/PDFs gdrive:RClone/PDFs --verbose --check-access >> /home/alan/.rclone.log 2>&1
	rclone bisync /mnt/DiscoExterno/Users/Alan/Documents/_Arquivos/Office gdrive:RClone/Office --verbose --check-access >> /home/alan/.rclone.log 2>&1

	rclone bisync /mnt/DiscoExterno/Users/Alan/Documents/_Codes/Markdown/USP gdrive:RClone/USP --verbose --check-access >> /home/alan/.rclone.log 2>&1
fi


