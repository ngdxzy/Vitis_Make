FOLDER_NAME=$1

aws ec2 describe-fpga-images --fpga-image-ids=$(cat $FOLDER_NAME/*_afi_id.txt | grep afi- | sed 's/^.*\(afi-[^"]*\).*/\1/' )
