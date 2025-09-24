function finalTemp = getFinalCoolantTemp(L_contact,D,q,mDot_fuel,c_fuel,T_l)
fuelContactArea   = L_contact.*pi.*D;
finalTemp = T_l + sum(q.*fuelContactArea)/(mDot_fuel*c_fuel);
end