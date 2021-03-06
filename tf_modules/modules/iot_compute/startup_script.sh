# define temporary environment path variables
# if you save files to root directory, it can not be easily found
iot_directory="/home/$your_username/iot"
files_directory="/training-data-analyst/quests/iotlab/"
demo_directory="$iot_directory$files_directory"

# update the system information about Debian Linux package repositories
sudo apt-get update

# install in scope packages
sudo apt-get install python-pip openssl git git-core -y

# use pip for needed Python components
sudo pip install pyjwt paho-mqtt cryptography

# make a new directory
sudo mkdir -p $iot_directory

# add data to analyze
cd $iot_directory; git clone https://github.com/sungchun12/training-data-analyst.git

# create RSA cryptographic keypair
cd $demo_directory
sudo openssl req -x509 -newkey rsa:2048 -keyout rsa_private.pem \
-nodes -out rsa_cert.pem -subj "/CN=unused"

# download the CA root certificates from pki.google.com to the appropriate directory
sudo wget https://pki.google.com/roots.pem

# install gcloud sdk for cli commands
sudo apt-get install google-cloud-sdk

# set environment variables for creating devices on IOT registry
MY_REGION=us-central1
IOT_REGISTRY=iot-registry
DEVICE_ID=temp-sensor-$RANDOM # randomly generated integer id

# create example temperature sensor
gcloud beta iot devices create $DEVICE_ID \
--project=$PROJECT_ID \
--region=$MY_REGION \
--registry=$IOT_REGISTRY \
--public-key path=rsa_cert.pem,type=rs256

# run the simulated device in the background
sudo python cloudiot_mqtt_example_json.py \
--project_id=$PROJECT_ID \
--cloud_region=$MY_REGION \
--registry_id=$IOT_REGISTRY \
--device_id=$DEVICE_ID \
--private_key_file=rsa_private.pem \
--message_type=event \
--num_messages=5000 \
--algorithm=RS256 > $DEVICE_ID-log.txt 2>&1 &