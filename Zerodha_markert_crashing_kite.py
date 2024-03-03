import yaml
import time
from kite_trade import *

user_id = ""       # Login Id
password = ""      # Login password
twofa = ""         # Login Pin or TOTP
 
 
print("---- Appsportal.in Tool for MT4 Algo Bridge Shoonya Finvasia ----")
print("---- Developer - Sandip Ram Pawar, 9423950322 ----")
print("---- visit www.Appsportal.in for More helpful Tools ----")

print("---- -- ----")

print("---- Risk Disclaimer ----")
print("By using the services offered by appsportal.in, or using this tool the user agrees that the author and any other entities associated with the appsportal.in shall not be held liable for any direct, indirect, consequential loss or any damages whatsoever arising from this usage, or the use of any information, signals, messages, education, and any other information contained or disseminated in regard to its use and understanding.")
print("Use this tool and the services offered by appsportal.in at your own risk. Neither guarantee of performance results nor any anticipated return on investment is offered at any time.")
print("Remember Past performance is no guarantee of future results.")

print("==== -- ====")
 

username = input("Enter your enctoken: ")

# //cred    ===  user     ===  
enctoken   = username

kite = KiteApp(enctoken=enctoken)
 

try:
    print("Net Balance : ", kite.margins()["equity"]['net'])
except:
    print("Login Failed!!!!")
    time.sleep(3) 
    sys.exit()


import zmq
import random
import os, sys
import    json
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

with open('cred2.yml') as f:
    cred = yaml.load(f, Loader=yaml.FullLoader)
    print(cred)

response = requests.get('http://mobi.newsalert.xyz/Mt4License.asmx/HelloWorld?Lid='+ cred['Lid'] + '&Pid=' + cred['Pid'] ).json()

try:
    enable_mode  =  response['Active']
except:
  print("License Not Valid or Expired ! Visit Appsportal.in or Contact Admin.")
  time.sleep(5) 
  # print(ret)

print ( "===================")

 

ctx = zmq.Context()
sock = ctx.socket(zmq.SUB)
sock.connect("tcp://:5556")
sock.subscribe("") # Subscribe to all topics
previous_ticket  =   0
active_trade_type  =   -1
enable_nifty    =  False
data_ret    =  hit()  
print("Starting receiver loop ...")
while True and enable_mode  ==  1:
    msg = sock.recv_string()
    print("Received string: %s ..." % msg)
    if len(msg.split(" "))>0 :
        # 
        msg_mapping   =  len(msg.split(" "))-1
        data = msg.split(" ")[msg_mapping]

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
                
                print(time_trade  ,  symbol_name  ,  signal_type , signal_quantity  , exchange_type ,  price_type_signal)

 
                try:
                    order = kite.place_order(variety=kite.VARIETY_REGULAR,
                            exchange=exchange_type,
                            tradingsymbol=symbol_name,
                            transaction_type=signal_type,
                            quantity=signal_quantity,
                            product=kite.PRODUCT_MIS,
                            order_type=kite.ORDER_TYPE_MARKET,
                            price=None,
                            validity=None,
                            disclosed_quantity=None,
                            trigger_price=None,
                            squareoff=None,
                            stoploss=None,
                            trailing_stoploss=None,
                            tag="TradeViaPython")
                    print(order)                  
                except :
                    print ("Wrong  pramatere")





sock.close()
ctx.term()

