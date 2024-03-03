import time
import zmq
import random
import os, sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from api_helper import ShoonyaApiPy
import logging
import yaml
import datetime
import timeit
import pyotp
from   finvasia import hit
import  requests
#get current time
import  json
d = datetime.datetime.now()

#print date
print(d)
print("---- Appsportal.in Tool for MT4 Algo Bridge Shoonya Finvasia ----")
print("---- Developer - Sandip Ram Pawar, 9423950322 ----")
print("---- visit www.Appsportal.in for More helpful Tools ----")

print("---- -- ----")

print("---- Risk Disclaimer ----")
print("By using the services offered by appsportal.in, or using this tool the user agrees that the author and any other entities associated with the appsportal.in shall not be held liable for any direct, indirect, consequential loss or any damages whatsoever arising from this usage, or the use of any information, signals, messages, education, and any other information contained or disseminated in regard to its use and understanding.")
print("Use this tool and the services offered by appsportal.in at your own risk. Neither guarantee of performance results nor any anticipated return on investment is offered at any time.")
print("Remember Past performance is no guarantee of future results.")

print("==== -- ====")
 


data_ret    =  hit()  
month_data  =  d.strftime("%b") 
month_final =  month_data.upper()

 
api = ShoonyaApiPy()

indian_pair     = [  "NIFTYFUT"   ,   "BANKNIFTYFUT"]
indian_pair_nfo   = [  "BANKNIFTY JAN FUT"    , "NIFTY JAN FUT"]
indian_pair_nfo_symbol_generator  =    [   ]
count_data  =  0 
for   iterate_data  in  indian_pair_nfo :
 
    indian_pair_nfo[count_data]    =   iterate_data.replace("JAN"   ,month_final )
    count_data     = count_data   +  1


print   (  indian_pair_nfo  ,  "indian_pair_nfo   " )
  

with open('cred2.yml') as f:
    cred = yaml.load(f, Loader=yaml.FullLoader)
    # print(cred)

response = requests.get('http://mobi.newsalert.xyz/Mt4License.asmx/HelloWorld?Lid='+ cred['Lid'] + '&Pid=' + cred['Pid'] ).json()

try:
    enable_mode  =  response['Active']
except:
  print("License Not Valid or Expired ! Visit Appsportal.in or Contact Admin.")
  time.sleep(5) 
 

totp = pyotp.TOTP(cred['totp'])
factor_mapping_2    =  totp.now()
ret = api.login(userid = cred['user'], password = cred['pwd'], twoFA=factor_mapping_2, vendor_code=cred['vc'], api_secret=cred['apikey'], imei=cred['imei'])

 


print ( "===================")
 
print ( "=====================  lllllllllllll")



ctx = zmq.Context()
sock = ctx.socket(zmq.SUB)
sock.connect("tcp://:5556")
sock.subscribe("")  
previous_ticket  =   0
active_trade_type  =   0
enable_nifty    =  False

print("Starting receiver loop ...")

while True and enable_mode  ==  1:
    
    msg = sock.recv_string()
    print("Received string: %s ..." % msg)
  
    if len(msg.split(" "))>0:
        # 
        msg_mapping   =  len(msg.split(" "))-1
        data = msg.split(" ")[msg_mapping]
        print()
        if  len(data.split("ENDOF"))  >  0 :
 
            for   i   in range  ( 0 , len(data.split("ENDOF"))-1) :

                print("=================================FFF",data.split("ENDOF")  )
                print  ( (data.split("ENDOF")[i]).split("@")   )
                time_trade    =   (data.split("ENDOF")[i]).split("@")[0]
                symbol_name    =  (data.split("ENDOF")[i]).split("@")[1] 
                signal_type  =  (data.split("ENDOF")[i]).split("@")[2] 
                signal_quantity   =  (data.split("ENDOF")[i]).split("@")[3] 
                exchange_type   =  (data.split("ENDOF")[i]).split("@")[4] 
                price_type_signal    =  (data.split("ENDOF")[i]).split("@")[5]



                
                api.place_order(buy_or_sell= signal_type, product_type='I',
                exchange=exchange_type, tradingsymbol= symbol_name,
                quantity=signal_quantity, discloseqty=0,price_type= price_type_signal, price=0,
                trigger_price=None,
                retention='DAY', remarks='my_order_0015') 
                
                
         
sock.close()
ctx.term()

 
