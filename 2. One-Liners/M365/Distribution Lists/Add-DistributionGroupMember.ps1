#Connect to Exchange Online
Connect-ExchangeOnline -ShowBanner:$False

#Add User to the Distribution Group
Add-DistributionGroupMember –Identity "Sales@Crescent.com" -Member "Steve@Crescent.com"