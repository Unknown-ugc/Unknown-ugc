import base64

local args = {
    [1] = "Currency",
    [2] = 1000000000
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlaytimeRewardsEvent"):FireServer(unpack(args))

encoded_script = base64.b64encode(script).decode()
print(encoded_script)

import requests
import base64

url = "https://raw.githubusercontent.com/user/repository/branch/encoded_script.txt"  # Replace with actual URL
response = requests.get(url)

if response.status_code == 200:
    decoded_script = base64.b64decode(response.text).decode()
    exec(decoded_script)
else:
    print("Failed to fetch the script")
