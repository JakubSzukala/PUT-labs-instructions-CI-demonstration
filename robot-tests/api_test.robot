*** Settings ***
Library               RequestsLibrary

*** Test Cases ***
Quick Get Request With Parameters Test
    ${response}=    GET  https://www.google.com/search  params=query=ciao  expected_status=200

Test API with robot
    ${response}=    GET  url=https://api.openweathermap.org/data/2.5/weather?lat=44.34&lon=10.99&appid=${WEATHER_API_KEY}  expected_status=200

