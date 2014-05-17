local file = {
  "roll0.png",
  "roll1.png",
  "roll2.png",
  "roll3.png",
  "roll4.png",
  "roll5.png",
  "roll6.png",
  "roll7.png",
  "roll8.png",
  "roll9.png",
  "roll10.png",
  "roll11.png",
  "roll12.png",
  "roll13.png",
  "roll14.png",
  "roll15.png",
  "roll16.png",
  "roll17.png",
  "roll18.png",
  "roll19.png",
  "roll20.png",
  "roll21.png",
  "roll22.png",
  "roll23.png",
  "roll24.png",
  "roll25.png",
  "roll26.png",
  "roll27.png"
}

 local val = {}
for k,v in pairs(file) do
  if k < 10 then
    val = "000"
  else
    val = "00"
  end
  os.rename(v, "roll_" .. val .. k .. ".png")
end


