--[[
--  auto fragmentation test
--]]
--
broadcast_blob={}
broadcast_blob.__index=broadcast_blob

broadcast_blob["init"]=function()
  bcast:create(2000);
  broadcast_blob["nap"]=nap:new();
end

broadcast_blob["run"]=function()
  print("running")
  local oon=nljson.decode([[{
      "cid" : 6,
      "message" : [ 1, 2, 3 ,4 ,5,
      "ooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooo______oooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\noooooo___oooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\noooooo___oooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\noooooo___oooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\noooooo___oooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\noooooo___oooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\noooooo___ooooooooo OOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\noooooo_____________OOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOooooooo     oooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOooooo   oo   ooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooo   oooo   oooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoo   oooooo   oooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOo   oooooooo   ooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOo               oooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOO   oooooooooooo   ooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOO      oooooooooo      ooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOooo           oooooooOO          OOOOooooooooooo\nooooooooooooooooooOOOOOOOOOooo  ooooooooo ooooooOO  OOOOOOOO OOOooooooooooo\nooooooooooooooooooOOOOOOOOOooo  oooooooooo oooooOO  OOOOOOOOO OOooooooooooo\nooooooooooooooooooOOOOOOOOOooo  oooooooooo oooooOO  OOOOOOOOO OOooooooooooo\nooooooooooooooooooOOOOOOOOOooo  ooooooooo ooooooOO  OOOOOOOO OOOooooooooooo\nooooooooooooooooooOOOOOOOOOooo           oooooooOO          OOOOooooooooooo\nooooooooooooooooooOOOOOOOOOooo  ooooooooooooooooOO  OOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOooo  ooooooooooooooooOO  OOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOooo  ooooooooooooooooOO  OOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOooo  ooooooooooooooooOO  OOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOO           oooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOO   OOOOOOOooo ooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOO  OOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOO OOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOO  OOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOO  OOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOO  OOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOO   oooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOO OOOOOOOOOo   ooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOO OOOOOOOOOo   ooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOO            oooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo\nooooooooooooooooooOOOOOOOOOoooooooooooooooooooooOOOOOOOOOOOOOOOOooooooooooo" 
      ]
  }]]);
  while true
  do
    broadcast_blob.nap:usleep(5000000);
    bcast:send(2000,oon);
    if(must_stop())
    then
      break;
    end
  end
end

return broadcast_blob;
