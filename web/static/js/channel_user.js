import socket from "./socket"

// Now that you are connected, you can join channels with a topic:
let userChannel = socket.channel(`user`)

userChannel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default userChannel