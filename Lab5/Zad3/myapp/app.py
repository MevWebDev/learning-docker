import requests

def fetch_example():
    url = "https://jsonplaceholder.typicode.com/todos/1"
    response = requests.get(url)
    if response.ok:
        print("Fetched data:", response.json())
    else:
        print("Failed to fetch data.")

if __name__ == "__main__":
    print("Hello from Python using requests!")
    fetch_example()