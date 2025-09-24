function elasticModulus = getElasticModulus(materialName, deg_C, percentDeformation)
mat = getMaterialProperties(materialName);

elasticModulus = mat.getYieldStrength(deg_C)/(percentDeformation/100);

end