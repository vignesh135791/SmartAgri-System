import asyncio
import os
import websockets

async def test_raw():
    uri = os.getenv("SMARTAGRI_WS_URL", "ws://localhost:8000/ws")
    print(f"Connecting to {uri}...")
    try:
        async with websockets.connect(uri) as websocket:
            print("Connected! Listening for raw messages...")
            # Set a timeout for the first message
            try:
                while True:
                    message = await asyncio.wait_for(websocket.recv(), timeout=10)
                    print(f"RAW MESSAGE RECEIVED: {message[:200]}...")
            except asyncio.TimeoutError:
                print("TIMEOUT: No message received in 10 seconds.")
    except Exception as e:
        print(f"Connection failed: {e}")

if __name__ == "__main__":
    asyncio.run(test_raw())
