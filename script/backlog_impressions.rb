csv_text = "/4390/smoke-n-mirrors,19
/AgustinP/a-people-counter-with-raspberry-pi-and-ubidots,21
/akellyirl/arduino-raspberry-pi-internet-radio,16
/alinan/wireless-iot-mqtt-super-mario-bros-coin-box,14
/anthony-ngu/open-source-home-hub,120
/Ashraf_Nabil/tracking-and-controlling-your-car-remotely-using-arduino-and,26
/contractorwolf/pebblesmartgarage,41
/craig-mulligan/occupied,37
/Dan/mini-weather,23
/daniel0524/building-a-wifi-outlet,87
/dronix-alter-ego/dronixcar,27
/edwios/connecting-a-kitchen-scale-part-1,23
/eely22/spark-bluz-powered-smart-lock,390
/ender-override-1/fishy-machine,19
/erictsai/uber-home-automation,90
/erictsai/udoo-baby-room-automation,31
/fablabeu/the-sensable-thing,49
/jay_uk/letterbot,48
/martin-diego-costas-gonzalez/carpc-android,12
/Mudshark/home-monitor,21
/nelemansc/smartcoffee,34
/nzlamb/vocore-airplay-server,23
/pipeaguirres/homer-door-wifi-sensor,21
/rayburne/10-arduino-o-scope,20
/rayburne/4-dollar-90-mips-32-bit-72-mhz-arm-arduino,70
/rayburne/arduino-stm32,16
/rayburne/arduino-to-excel-using-v-usb,49
/rayburne/magic-morse-on-arduino,17
/rayburne/maple-mini-clone-update,29
/rayburne/oled-on-the-cheap,36
/resin-io/safe-deposit-box-with-two-factor-authentication,21
/stabilorose/stabilorose,25
/sunny-gleason/programming-a-tessel-camera-app-with-javascript,24
/umangrajdev/internet-of-things-in-heathcare,45
/windows-iot-maker/build-hands-on-lab-iot-weather-station-using-windows-10,79
/windowsiot/basic-windows-remote-arduino,2375
/windowsiot/blinky-webserver-sample,99
/windowsiot/hello-blinky-with-galileo-and-windows,61
/windowsiot/i2c-accelerometer-sample,203
/windowsiot/memorystatus-console-application-sample,41
/windowsiot/picture-of-the-weather,2576
/windowsiot/powershell-to-connect-to-a-machine-running-windows-10,513
/windowsiot/push-button-sample,411
/windowsiot/robot-kit,709
/windowsiot/shift-register-sample,368
/yleguesse/spark-non-invasive-smart-electricity-meter,36"

require 'csv'

csv = CSV.parse(csv_text, headers: false)
csv.each do |row|
  slug = row[0][1..-1]
  count = row[1].to_i
  project = Project.includes(:slug_histories).references(:slug_histories).where("LOWER(slug_histories.value) = ?", slug).first
  next unless project
  count = (count * 0.8).to_i
  puts count.to_s
  count.times do
    Impression.create(impressionable_type: 'Project', impressionable_id: project.id, session_hash: SecureRandom.hex(16), controller_name: :'projects', action_name: 'show', message: 'backlog')
  end
end