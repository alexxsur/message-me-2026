import consumer from "channels/consumer"

const scrollToBottom = () => {
  const container = document.getElementById("messages-container")
  if (container) container.scrollTop = container.scrollHeight
}

document.addEventListener("turbo:load", scrollToBottom)

consumer.subscriptions.create("ChatroomChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    const list = document.getElementById("messages")
    if (!list) return
    const li = document.createElement("li")
    const em = document.createElement("em")
    em.textContent = `${data.user.username}: `
    li.append(em, document.createTextNode(data.body))
    list.appendChild(li)
    scrollToBottom()
  }
});
