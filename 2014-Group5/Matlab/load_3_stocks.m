% Information Retrieval and Data Mining
% University College London 2013/2014
% Coursework 2

% Daily closing price The final price at which a security is traded on a given trading day
% Daily traded volume The volume which is traded on a given trading day
% Daily price change The change in the price of a stock from the previous trading day's close to the current day's close
% Daily absolute price change The norm for computing asset performance change

% Features: Y --> pos1: volume traded, pos2: closing price, pos3: daily change price
% pos 4: abs daily change price

function [Yibm,Yintel,Yge]=load_3_stocks()

%ibm=csvread('stock-prices/IBM.csv',1,0); % skip first row 
A = importdata('stock-prices/IBM.csv',',',1);
ibm=A.data;
ibm=flipud(ibm);
A = importdata('stock-prices/GE.csv',',',1);
ge=A.data;
ge=flipud(ge);
A = importdata('stock-prices/intel.csv',',',1);
intel=A.data;
intel=flipud(intel);

% pos1: Open, pos2: High, pos3: Low, pos4: Close, pos5: Volume
% pos6: Adj Close

Yibm=zeros(50,1);
Yintel=zeros(50,1);
Yge=zeros(50,1);

% Days: 
% 13/01, 14/01, 15/01, 16/01, 17/01, 18/01*, 19/01*, 20/01*,
% 21/01, 22/01, 23/01, 24/01, 25/01*, 26/01*, 27/01, 28/01, 29/01, 30/01,
% 31/01
% Total days Jan: 19 (5 fake)
% 1/02*, 2/02*, 3/02, 4/02, 5/02, 6/02, 7/02, 8/02*, 9/02*, 10/02, 11/02,
% 12/02, 13/02, 14/02, 15/02*, 16/02*, 17/02*, 18/02, 19/02, 20/02, 21/02,
% 22/02*, 23/02*, 24/02, 25/02, 26/02, 27/02, 28/02
% Total days Feb: 28 (9 fake)
% 1/02*, 2/03*, 3/03
% Total days Mar: 3 (2 fake)
% --
% Total days: 50 (16 fake)

% 5-3*-4-2*-5-2*-5-2*-5-3*-4-2*-5-2*-1


% ibm on 10/01:   18,770.00	18,770.00	18,638.00	18,687.00	300	18,584.61
% intel on 10/01: 25.50	25.85	25.50	25.53	30,588,800	25.29
% ge on 10/01:    27.19 27.23	26.86	26.96	38,828,600	26.73


%% IBM

% 5 
Yibm(1:5,1)=ibm(1:5,5);
Yibm(1:5,2)=ibm(1:5,4);
Yibm(1,3)=ibm(1,4)-18687;
Yibm(2:5,3)=ibm(2:5,4)-ibm(1:4,4);
Yibm(1:5,4)=abs(Yibm(1:5,3));
% 3*
Yibm(6:8,1)=repmat(ibm(5,5),3,1);
Yibm(6:8,2)=repmat(ibm(5,4),3,1);
Yibm(6:8,3)=repmat(Yibm(5,3),3,1);
Yibm(6:8,4)=abs(Yibm(6:8,3));
% 4
Yibm(9:12,1)=ibm(6:9,5);
Yibm(9:12,2)=ibm(6:9,4);
Yibm(9:12,3)=ibm(6:9,4)-ibm(5:8,4);
Yibm(9:12,4)=abs(Yibm(9:12,3));
% 2*
Yibm(13:14,1)=repmat(ibm(9,5),2,1);
Yibm(13:14,2)=repmat(ibm(9,4),2,1);
Yibm(13:14,3)=repmat(Yibm(12,3),2,1);
Yibm(13:14,4)=abs(Yibm(13:14,3));
% 5
Yibm(15:19,1)=ibm(10:14,5);
Yibm(15:19,2)=ibm(10:14,4);
Yibm(15:19,3)=ibm(10:14,4)-ibm(9:13,4);
Yibm(15:19,4)=abs(Yibm(15:19,3));
% 2*
Yibm(20:21,1)=repmat(ibm(14,5),2,1);
Yibm(20:21,2)=repmat(ibm(14,4),2,1);
Yibm(20:21,3)=repmat(Yibm(19,3),2,1);
Yibm(20:21,4)=abs(Yibm(20:21,3));
% 5
Yibm(22:26,1)=ibm(15:19,5);
Yibm(22:26,2)=ibm(15:19,4);
Yibm(22:26,3)=ibm(15:19,4)-ibm(14:18,4);
Yibm(22:26,4)=abs(Yibm(15:19,3));
% 2*
Yibm(27:28,1)=repmat(ibm(19,5),2,1);
Yibm(27:28,2)=repmat(ibm(19,4),2,1);
Yibm(27:28,3)=repmat(Yibm(26,3),2,1);
Yibm(27:28,4)=abs(Yibm(27:28,3));
% 5
Yibm(29:33,1)=ibm(20:24,5);
Yibm(29:33,2)=ibm(20:24,4);
Yibm(29:33,3)=ibm(20:24,4)-ibm(19:23,4);
Yibm(29:33,4)=abs(Yibm(20:24,3));
% 3*
Yibm(34:36,1)=repmat(ibm(24,5),3,1);
Yibm(34:36,2)=repmat(ibm(24,4),3,1);
Yibm(34:36,3)=repmat(Yibm(33,3),3,1);
Yibm(34:36,4)=abs(Yibm(34:36,3));
% 4
Yibm(37:40,1)=ibm(25:28,5);
Yibm(37:40,2)=ibm(25:28,4);
Yibm(37:40,3)=ibm(25:28,4)-ibm(24:27,4);
Yibm(37:40,4)=abs(Yibm(25:28,3));
% 2*
Yibm(41:42,1)=repmat(ibm(28,5),2,1);
Yibm(41:42,2)=repmat(ibm(28,4),2,1);
Yibm(41:42,3)=repmat(Yibm(40,3),2,1);
Yibm(41:42,4)=abs(Yibm(41:42,3));
% 5
Yibm(43:47,1)=ibm(29:33,5);
Yibm(43:47,2)=ibm(29:33,4);
Yibm(43:47,3)=ibm(29:33,4)-ibm(28:32,4);
Yibm(43:47,4)=abs(Yibm(29:33,3));
% 2*
Yibm(48:49,1)=repmat(ibm(33,5),2,1);
Yibm(48:49,2)=repmat(ibm(33,4),2,1);
Yibm(48:49,3)=repmat(Yibm(47,3),2,1);
Yibm(48:49,4)=abs(Yibm(48:49,3));
% 1
Yibm(50,1)=ibm(34,5);
Yibm(50,2)=ibm(34,4);
Yibm(50,3)=ibm(34,4)-ibm(33,4);
Yibm(50,4)=abs(Yibm(34,3));


%% GE

% 5 
Yge(1:5,1)=ge(1:5,5);
Yge(1:5,2)=ge(1:5,4);
Yge(1,3)=ge(1,4)-26.96;
Yge(2:5,3)=ge(2:5,4)-ge(1:4,4);
Yge(1:5,4)=abs(Yge(1:5,3));
% 3*
Yge(6:8,1)=repmat(ge(5,5),3,1);
Yge(6:8,2)=repmat(ge(5,4),3,1);
Yge(6:8,3)=repmat(Yge(5,3),3,1);
Yge(6:8,4)=abs(Yge(6:8,3));
% 4
Yge(9:12,1)=ge(6:9,5);
Yge(9:12,2)=ge(6:9,4);
Yge(9:12,3)=ge(6:9,4)-ge(5:8,4);
Yge(9:12,4)=abs(Yge(9:12,3));
% 2*
Yge(13:14,1)=repmat(ge(9,5),2,1);
Yge(13:14,2)=repmat(ge(9,4),2,1);
Yge(13:14,3)=repmat(Yge(12,3),2,1);
Yge(13:14,4)=abs(Yge(13:14,3));
% 5
Yge(15:19,1)=ge(10:14,5);
Yge(15:19,2)=ge(10:14,4);
Yge(15:19,3)=ge(10:14,4)-ge(9:13,4);
Yge(15:19,4)=abs(Yge(15:19,3));
% 2*
Yge(20:21,1)=repmat(ge(14,5),2,1);
Yge(20:21,2)=repmat(ge(14,4),2,1);
Yge(20:21,3)=repmat(Yge(19,3),2,1);
Yge(20:21,4)=abs(Yge(20:21,3));
% 5
Yge(22:26,1)=ge(15:19,5);
Yge(22:26,2)=ge(15:19,4);
Yge(22:26,3)=ge(15:19,4)-ge(14:18,4);
Yge(22:26,4)=abs(Yge(15:19,3));
% 2*
Yge(27:28,1)=repmat(ge(19,5),2,1);
Yge(27:28,2)=repmat(ge(19,4),2,1);
Yge(27:28,3)=repmat(Yge(26,3),2,1);
Yge(27:28,4)=abs(Yge(27:28,3));
% 5
Yge(29:33,1)=ge(20:24,5);
Yge(29:33,2)=ge(20:24,4);
Yge(29:33,3)=ge(20:24,4)-ge(19:23,4);
Yge(29:33,4)=abs(Yge(20:24,3));
% 3*
Yge(34:36,1)=repmat(ge(24,5),3,1);
Yge(34:36,2)=repmat(ge(24,4),3,1);
Yge(34:36,3)=repmat(Yge(33,3),3,1);
Yge(34:36,4)=abs(Yge(34:36,3));
% 4
Yge(37:40,1)=ge(25:28,5);
Yge(37:40,2)=ge(25:28,4);
Yge(37:40,3)=ge(25:28,4)-ge(24:27,4);
Yge(37:40,4)=abs(Yge(25:28,3));
% 2*
Yge(41:42,1)=repmat(ge(28,5),2,1);
Yge(41:42,2)=repmat(ge(28,4),2,1);
Yge(41:42,3)=repmat(Yge(40,3),2,1);
Yge(41:42,4)=abs(Yge(41:42,3));
% 5
Yge(43:47,1)=ge(29:33,5);
Yge(43:47,2)=ge(29:33,4);
Yge(43:47,3)=ge(29:33,4)-ge(28:32,4);
Yge(43:47,4)=abs(Yge(29:33,3));
% 2*
Yge(48:49,1)=repmat(ge(33,5),2,1);
Yge(48:49,2)=repmat(ge(33,4),2,1);
Yge(48:49,3)=repmat(Yge(47,3),2,1);
Yge(48:49,4)=abs(Yge(48:49,3));
% 1
Yge(50,1)=ge(34,5);
Yge(50,2)=ge(34,4);
Yge(50,3)=ge(34,4)-ge(33,4);
Yge(50,4)=abs(Yge(34,3));

%% Intel

% 5 
Yintel(1:5,1)=intel(1:5,5);
Yintel(1:5,2)=intel(1:5,4);
Yintel(1,3)=intel(1,4)-25.53;
Yintel(2:5,3)=intel(2:5,4)-intel(1:4,4);
Yintel(1:5,4)=abs(Yintel(1:5,3));
% 3*
Yintel(6:8,1)=repmat(intel(5,5),3,1);
Yintel(6:8,2)=repmat(intel(5,4),3,1);
Yintel(6:8,3)=repmat(Yintel(5,3),3,1);
Yintel(6:8,4)=abs(Yintel(6:8,3));
% 4
Yintel(9:12,1)=intel(6:9,5);
Yintel(9:12,2)=intel(6:9,4);
Yintel(9:12,3)=intel(6:9,4)-intel(5:8,4);
Yintel(9:12,4)=abs(Yintel(9:12,3));
% 2*
Yintel(13:14,1)=repmat(intel(9,5),2,1);
Yintel(13:14,2)=repmat(intel(9,4),2,1);
Yintel(13:14,3)=repmat(Yintel(12,3),2,1);
Yintel(13:14,4)=abs(Yintel(13:14,3));
% 5
Yintel(15:19,1)=intel(10:14,5);
Yintel(15:19,2)=intel(10:14,4);
Yintel(15:19,3)=intel(10:14,4)-intel(9:13,4);
Yintel(15:19,4)=abs(Yintel(15:19,3));
% 2*
Yintel(20:21,1)=repmat(intel(14,5),2,1);
Yintel(20:21,2)=repmat(intel(14,4),2,1);
Yintel(20:21,3)=repmat(Yintel(19,3),2,1);
Yintel(20:21,4)=abs(Yintel(20:21,3));
% 5
Yintel(22:26,1)=intel(15:19,5);
Yintel(22:26,2)=intel(15:19,4);
Yintel(22:26,3)=intel(15:19,4)-intel(14:18,4);
Yintel(22:26,4)=abs(Yintel(15:19,3));
% 2*
Yintel(27:28,1)=repmat(intel(19,5),2,1);
Yintel(27:28,2)=repmat(intel(19,4),2,1);
Yintel(27:28,3)=repmat(Yintel(26,3),2,1);
Yintel(27:28,4)=abs(Yintel(27:28,3));
% 5
Yintel(29:33,1)=intel(20:24,5);
Yintel(29:33,2)=intel(20:24,4);
Yintel(29:33,3)=intel(20:24,4)-intel(19:23,4);
Yintel(29:33,4)=abs(Yintel(20:24,3));
% 3*
Yintel(34:36,1)=repmat(intel(24,5),3,1);
Yintel(34:36,2)=repmat(intel(24,4),3,1);
Yintel(34:36,3)=repmat(Yintel(33,3),3,1);
Yintel(34:36,4)=abs(Yintel(34:36,3));
% 4
Yintel(37:40,1)=intel(25:28,5);
Yintel(37:40,2)=intel(25:28,4);
Yintel(37:40,3)=intel(25:28,4)-intel(24:27,4);
Yintel(37:40,4)=abs(Yintel(25:28,3));
% 2*
Yintel(41:42,1)=repmat(intel(28,5),2,1);
Yintel(41:42,2)=repmat(intel(28,4),2,1);
Yintel(41:42,3)=repmat(Yintel(40,3),2,1);
Yintel(41:42,4)=abs(Yintel(41:42,3));
% 5
Yintel(43:47,1)=intel(29:33,5);
Yintel(43:47,2)=intel(29:33,4);
Yintel(43:47,3)=intel(29:33,4)-intel(28:32,4);
Yintel(43:47,4)=abs(Yintel(29:33,3));
% 2*
Yintel(48:49,1)=repmat(intel(33,5),2,1);
Yintel(48:49,2)=repmat(intel(33,4),2,1);
Yintel(48:49,3)=repmat(Yintel(47,3),2,1);
Yintel(48:49,4)=abs(Yintel(48:49,3));
% 1
Yintel(50,1)=intel(34,5);
Yintel(50,2)=intel(34,4);
Yintel(50,3)=intel(34,4)-intel(33,4);
Yintel(50,4)=abs(Yintel(34,3));

pi;




