
player_url="https://www.lynda.com/MySQL-tutorials/MySQL-Essential-Training/139986-2.html"





rm cookiefile
curl -L -c cookiefile \
-H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0"  https://www.lynda.com/portal/sip?org=libraries.sa.gov.au  -o login.html
seasurf=`cat login.html | grep 'id="seasurf" name="seasurf"' | awk -F'value="' '{ print $2 }' | awk -F'" />' '{ print $1 }'`
curl -L -c cookiefile -b cookiefile --data "currentView=login&libraryCardNumber=1346618&libraryCardPasswordVerify=&libraryCardPin=1234&org=libraries.sa.gov.au&seasurf=${seasurf}"  \
-H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0"  https://www.lynda.com/portal/sip?org=libraries.sa.gov.au -o user.html

if [ "`cat user.html | grep "Enter your library card number and PIN to log in to lynda.com."`" != "" ] 
then
	echo "login fail, please try agin"
	exit
fi



player_type=`echo $player_url | awk -F'lynda.com/' '{ print $2 }' | awk -F'/' '{ print $1 }'`
player_name=`echo $player_url | awk -F"${player_type}/" '{ print $2 }' | awk -F'/' '{ print $1 }'`
player_id=`echo $player_url | awk -F"${player_name}/" '{ print $2 }' | awk -F'-' '{ print $1 }'`

curl -c cookiefile -b cookiefile \
-H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0"  ${player_url} -o video.html

cat video.html | grep "https://www.lynda.com/${player_type}/" |  awk -F'<a href="' '{ print $2 }' | grep  '" class="item-name video-name ga" role="listitem"' | awk -F'" class="item-name video-name ga"' '{ print $1 }' > play_list_url


mkdir -p "${player_type}/${player_name}"

while read -r line
do
    	video="$line"
	videoName=`echo $line | awk -F"${player_type}/" '{ print $2 }' | awk -F'/' '{ print $1 }' `
	videoId=`echo $line | awk -F"${player_id}/" '{ print $2 }' | awk -F'-' '{ print $1 }' `
	
	
	curl -c cookiefile -b cookiefile \
	-H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0"  https://www.lynda.com/ajax/course/${player_id}/${videoId}/play -o play_data
	
	cat play_data | awk -F'","urls":{' '{ print $2 }' | awk -F'},"qualities"' '{ print $1 }' > prossing_data
	sed -i -- 's:\\u0026:\&:g' prossing_data
	video_url=`cat prossing_data | awk -F'"720":"' '{ print $2 }' | awk -F'"' '{ print $1 }' `
	echo "${video_url} -o ${videoName}.mp4"
	echo "${player_type}/${player_name}/${videoName}.mp4"
	curl ${video_url} -o "${player_type}/${player_name}/${videoName}.mp4"
	#exit
sleep 1
done <  play_list_url
