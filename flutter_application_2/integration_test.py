import asyncio
import os
import websockets
import json

async def test_integration():
    uri = os.getenv("SMARTAGRI_WS_URL", "ws://localhost:8000/ws")
    print(f"Connecting to {uri}...")
    try:
        async with websockets.connect(uri) as websocket:
            print("Connected! Waiting for enriched data packet...")
            while True:
                message = await websocket.recv()
                try:
                    data = json.loads(message)
                    if data.get("type") == "enriched_data":
                        print("SUCCESS: Received Enriched Data Packet!")
                        print(f"Sensor Data Keys: {list(data.get('sensor_data', {}).keys())}")
                        print(f"Prediction Keys: {list(data.get('prediction', {}).keys())}")
                        print(f"Image Attached: {len(data.get('processed_image', '')) > 0}")
                        break
                    else:
                        print(f"Received other packet: {data.get('type')}")
                except Exception as e:
                    print(f"Error parsing message: {e}")
    except Exception as e:
        print(f"Connection failed: {e}")

if __name__ == "__main__":
    asyncio.run(test_integration())
