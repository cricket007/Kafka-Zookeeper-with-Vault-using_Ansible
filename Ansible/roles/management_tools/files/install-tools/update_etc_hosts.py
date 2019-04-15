import sys
import subprocess
import boto3


def updateHosts(kmaxInstances, zkmaxInstances, region):

    session = boto3.Session(profile_name='terraform', region_name=region)
    dynamodb = session.resource('dynamodb')
    ktable = dynamodb.Table('kafka-state')
    zktable = dynamodb.Table('zookeeper-state')

    try:
        response = ktable.get_item(
            Key={
                'state_name': 'kafka'
            }
        )
        print('the dynamodb response is: '+str(response))
        kdata = response['Item']
        print('the state stored in the dynamodb table is: '+str(kdata))
    except Exception as e:
        print('the exception is: '+str(e))
        if str(e) == '\'Item\'':
            print('there is no item the first time the table is read, ignore')
        else:
            raise e

    print (kdata)

    try:
        response = zktable.get_item(
            Key={
                'state_name': 'zookeeper'
            }
        )
        print('the dynamodb response is: '+str(response))
        zkdata = response['Item']
        print('the state stored in the dynamodb table is: '+str(zkdata))
    except Exception as e:
        print('the exception is: '+str(e))
        if str(e) == '\'Item\'':
            print('there is no item the first time the table is read, ignore')
        else:
            raise e

    print (zkdata)

    # update the kafka IP's
    index = 0
    print('the max kafka instances is: '+str(kmaxInstances))
    while index < int(kmaxInstances):
        try:
            index += 1
            print('kafka'+str(index))
            print("sudo python /tmp/install-tools/replaceAll.py /etc/hosts \'0.0.0.0 kafka"+str(index)+"\' \'"+kdata['kafka'+str(index)]+" kafka"+str(index)+"\'")
            subprocess.check_output("sudo python /tmp/install-tools/replaceAll.py /etc/hosts \'0.0.0.0 kafka"+str(index)+"\' \'"+kdata['kafka'+str(index)]+" kafka"+str(index)+"\'", shell=True, executable='/bin/bash')
        except Exception as e:
            print(e)
            raise e

    #update the zookeeper IP's
    index = 0
    print('the max zookeeper instances is: '+str(zkmaxInstances))
    while index < int(zkmaxInstances):
        index += 1
        print(index, zkdata['zookeeper'+str(index)])
        subprocess.check_output("sudo python /tmp/install-tools/replaceAll.py /etc/hosts \"0.0.0.0 zookeeper"+str(index)+"\" \""+zkdata['zookeeper'+str(index)]+" zookeeper"+str(index)+"\"", shell=True, executable='/bin/bash')

if __name__ == "__main__":
    print("This is the name of the script: ", sys.argv[0])
    print("Number of arguments: ", len(sys.argv))
    print("The arguments are: " , str(sys.argv))
    updateHosts(sys.argv[1],sys.argv[2],sys.argv[3])