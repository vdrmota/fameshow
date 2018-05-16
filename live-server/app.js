var express = require('express');
var app = express();
var server = require('http').Server(app)
var io = require('socket.io')(server)
var execPhp = require('exec-php');
var apn = require('apn');
const exec = require('child_process').exec;

app.use(express.static(__dirname + '/public'));
app.set('views', __dirname + '/public/views');
app.engine('html', require('ejs').renderFile);
app.set('view engine', 'html');

server.listen(process.env.PORT  || 3000)

var rooms = {}
var map_users = []
var streamer_users = []
var have_upvoted = []
var streamRoom = ""
var idToRoom = {}
var idToUser = {}
var idToMbps = {}
var streamId = ""
var upNextId = ""
var nextExists = false
var potentialStreamers = []
var voteCounter = 0
var viewerCounter = 0
const INTERVAL = 20
var counter = INTERVAL
const PAYOUT = 0.5
var payout = 0
var totalTime = 0
var percentage = 0
var additionalViewers = 0
var session = (new Date).getTime()
var threshold = 0.33
//var users_authenticated = {}
var showCounter = false
var upnext_queue = false
var queueupnext = ""
var liveRoom = ""
var updateRoom = true
var have_streamed = []
var no_stream = []
var is_genesis = false
const VERSION = "1.1"
var badWords = ["nigger", "negro", "fuck", "nudes", "boobs", "cock", "penis", "vagina", "suicide"];

function getKeyByValue(object, value) 
{
  return Object.keys(object).find(key => object[key] === value);
}

function countUnique(iterable) 
{
  return new Set(iterable).size;
}

Array.prototype.diff = function(a) {
    return this.filter(function(i) {return a.indexOf(i) < 0;});
};


app.get('/rooms', function(req, res) 
{

  if (liveRoom.length !== 0)
  {
    res.send([{"title":"fame","key":liveRoom,"version":VERSION}])
  }
  else
  {
    res.send([])
  }

})


app.get('/genesis', function(req, res) {

  //potentialStreamers = streamer_users.slice()

  potentialStreamers = map_users.slice()

  var winner = Math.floor(Math.random() * Math.floor(potentialStreamers.length))
  var winnerId = potentialStreamers.splice(winner)[0]

  var upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length))
  upNextId = potentialStreamers.splice(upNext)[0]

  nextExists = true

  io.sockets.emit('is_dead');
  io.sockets.connected[winnerId].emit("winner");
  io.sockets.connected[upNextId].emit("up_next");

  showCounter = true

  setTimeout(myFunction, 5000);

  function myFunction(){

    streamId = winnerId

    io.sockets.emit('new_room', idToRoom[winnerId])

    res.send("Winner: " + winnerId + ", Up next: " + upNextId);

  }

})

io.on('connection', function(socket) {

  //users_authenticated[socket.id] = false
  map_users.push(socket.id)
  viewerCounter = countUnique(map_users) + additionalViewers

  if (viewerCounter < 0)
  {
    viewerCounter = 0 + additionalViewers
  }

  socket.on('register_user', function(username) {

    idToUser[socket.id] = username
    idToMbps[socket.id] = 1

    //if (token == "welcometothefameshow")
    //{
    //  users_authenticated[socket.id] = true;
    //}

    console.log("[!CONNECTIONS!]")
    console.log(idToUser)
    console.log("[!END_CONNECTIONS!]")

  })

  socket.on('create_room', function(room) {

    if (!room.key) {
      return
    }

    //console.log('create room:', room)
    var roomKey = room.key
    rooms[roomKey] = room
    socket.roomKey = roomKey

    if (updateRoom === true)
    {
      if (streamRoom.length !== 0)
      {
        liveRoom = streamRoom
      }
      else
      {
        liveRoom = roomKey
      }
    }
    else
    {
      updateRoom = true
    }
    
    streamRoom = roomKey

    idToRoom[socket.id] = roomKey

    socket.join(roomKey)

    // store room in database
    execPhp('create.php', function(error, php, outprint)
    {
      php.my_function(roomKey, socket.id, idToUser[socket.id], session, function(err, result, output, printed)
      {
        console.log('!created: ' + roomKey)
      });
    });

  })

  socket.on('close_room', function(roomKey) {

    delete rooms[roomKey]

  })

  socket.on('toggle', function(streamer) {

  // false = doesn't want to stream

  if (streamer === false)
  {
    no_stream.push(socket.id)
  }
  else
  {
    no_stream = no_stream.filter(a => a !== socket.id)
  }
})

  socket.on('reconnect', function() {


  no_stream = no_stream.filter(a => a !== socket.id)

  map_users.push(socket.id)
  console.log('!reconnect: ', idToUser[socket.id])
  viewerCounter = countUnique(map_users) + additionalViewers

  if (viewerCounter < 0)
  {
    viewerCounter = 0 + additionalViewers
  }

  })

  socket.on('leave', function() {

    no_stream.push(socket.id)

    streamer_users = streamer_users.filter(a => a !== socket.id)
    map_users = map_users.filter(a => a !== socket.id)

    console.log('!leave: ', idToUser[socket.id])

    // check if user has been queued as up next
    if (upnext_queue === true)
    {
      if (queueupnext == socket.id)
      {
        upnext_queue = false
        queueupnext = ""
      }
    }

    // check if user is up next

    if (upNextId == socket.id)
    {

      console.log("IT WAS UPNEXT")

      var old_upNextId = upNextId

      updateRoom = false

      var potentialStreamers = (map_users.diff(have_streamed)).diff(no_stream); 
      potentialStreamers = potentialStreamers.filter(a => a !== upNextId)

      streamer_users = streamer_users.filter(a => a !== streamId)

      if (upnext_queue === true)
      {
        upNextId = queueupnext
        upnext_queue = false
      }
      else
      {
        upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
        upNextId = potentialStreamers.splice(upNext)[0];
      }

      io.sockets.connected[upNextId].emit("up_next");

      io.sockets.connected[old_upNextId].emit("terminate", session);

    }

    // check if user is streaming rn

    if (streamId == socket.id)
    {

      io.sockets.emit('message', "The streamer just disconnected. A new one will be up soon!")

      io.sockets.connected[streamId].emit("is_dead", streamRoom)

      var potentialStreamers = (map_users.diff(have_streamed)).diff(no_stream); // temporary

      potentialStreamers = potentialStreamers.filter(a => a !== streamId)

      streamId = upNextId

      potentialStreamers = potentialStreamers.filter(a => a !== streamId)

      io.sockets.connected[streamId].emit("is_live");

      // tell everybody what the new room is
      io.sockets.emit('new_room', streamRoom)

      if (upnext_queue === true)
      {
        upNextId = queueupnext
        upnext_queue = false
      }
      else
      {
        upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
        upNextId = potentialStreamers.splice(upNext)[0];
      }

      io.sockets.connected[upNextId].emit("up_next");

      totalTime = 0
      voteCounter = 0
      counter = INTERVAL
    }

    viewerCounter = countUnique(map_users) + additionalViewers

    if (viewerCounter < 0)
    {
      viewerCounter = 0 + additionalViewers
    }

    if (socket.roomKey) 
    {
      delete rooms[socket.roomKey]
    }
    else
    {
      //viewerCounter--
    }

  })

  socket.on('disconnect', function() {

    streamer_users = streamer_users.filter(a => a !== socket.id)
    map_users = map_users.filter(a => a !== socket.id)

    console.log('!disconnect: ', idToUser[socket.id])

    // check if user has been queued as up next
    if (upnext_queue === true)
    {
      if (queueupnext == socket.id)
      {
        upnext_queue = false
        queueupnext = ""
      }
    }

    // check if user is up next

    if (upNextId == socket.id)
    {

      updateRoom = false

      var potentialStreamers = (map_users.diff(have_streamed)).diff(no_stream);

      streamer_users = streamer_users.filter(a => a !== streamId)

      if (upnext_queue === true)
      {
        upNextId = queueupnext
        upnext_queue = false
      }
      else
      {
        upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
        upNextId = potentialStreamers.splice(upNext)[0];
      }

      io.sockets.connected[upNextId].emit("up_next");

    }

    // check if user is streaming rn

    if (streamId == socket.id)
    {

      io.sockets.emit('message', "The streamer just disconnected. A new one will be up soon!")

      var potentialStreamers = (map_users.diff(have_streamed)).diff(no_stream); // temporary

      potentialStreamers = potentialStreamers.filter(a => a !== streamId)

      streamId = upNextId

      potentialStreamers = potentialStreamers.filter(a => a !== streamId)

      io.sockets.connected[streamId].emit("is_live");

      // tell everybody what the new room is
      io.sockets.emit('new_room', streamRoom)

      if (upnext_queue === true)
      {
        upNextId = queueupnext
        upnext_queue = false
      }
      else
      {
        upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
        upNextId = potentialStreamers.splice(upNext)[0];
      }

      io.sockets.connected[upNextId].emit("up_next");

      totalTime = 0
      voteCounter = 0
      counter = INTERVAL
    }

    viewerCounter = countUnique(map_users) + additionalViewers

    if (viewerCounter < 0)
    {
      viewerCounter = 0 + additionalViewers
    }

    if (socket.roomKey) 
    {
      delete rooms[socket.roomKey]
    }
    else
    {
      //viewerCounter--
    }

    delete idToUser[socket.id]

  })

  socket.on('join_room', function(roomKey) {

    socket.join(roomKey)

    //viewerCounter++

  })

  socket.on('upvote', function(roomKey) {

    // check if person has already upvoted in this INTERVAL

    if (is_genesis)
    {

      if (!have_upvoted.includes(socket.id))
      {
        // user can upvote
        console.log('!upvote:', roomKey)
        voteCounter++

        have_upvoted.push(socket.id)
      }
      else
      {
        // user has already upvoted -- notify that user
        
      }

    }

    io.sockets.emit('upvote')

  })

  socket.on('comment', function(data) {
    if (badWords.some(function(v) { return data === v; })) 
    {
      // if bad words, tell that person
      io.sockets.connected[socket.id].emit('message', "Inappropriate comment!")
    }
    else
    {
      // if no bad words
      console.log('!comment by '+idToUser[socket.id]+':', data)
      io.sockets.emit('comment', data, idToUser[socket.id])
    }
  })

  socket.on('subscribe', function(currentRoom) {

    console.log('subscribe')

    broadcaster = idToUser[getKeyByValue(idToRoom, currentRoom)]
    subscriber = idToUser[socket.id]

    // store room in database
    execPhp('subscribe.php', function(error, php, outprint)
    {
      php.my_function(broadcaster, subscriber, session, function(err, result, output, printed)
      {

      });
    });

  })

  // setTimeout(function()
  // { 

  //   if (!users_authenticated[socket.id])
  //   {
  //     socket.disconnect()
  //   }

  // }, 5000);

})

setInterval(function() {

        if (viewerCounter != 0)
        {
          percentage = Math.abs((voteCounter / viewerCounter) / threshold)
        }
        else
        {
          percentage = 0
        }
        

        var result2 = {"viewers": viewerCounter, "votes": voteCounter, "time": counter, "%": percentage, "counter": showCounter};
        result2 = JSON.stringify(result2)
        console.log("!Tick: " + result2)

        io.sockets.emit('tick', viewerCounter, voteCounter, counter, percentage, showCounter)

        if (counter == 0)
        {

          console.log("[!BEGIN_ANALYTICS!]")
          console.log("[!CONNECTIONS!]")
          console.log(idToUser)
          console.log("[!END_CONNECTIONS!]")

          // reset votes
          voteCounter = 0

          if (viewerCounter != 0 && percentage >= 1)
          {
            // positive case
            counter = INTERVAL

            totalTime += INTERVAL

            io.sockets.connected[upNextId].emit('message', "The streamer was given more time. Your turn soon!")
          }
          else
          {
            // negative case
            counter = INTERVAL
            totalTime += INTERVAL

            payout = (totalTime / INTERVAL) * PAYOUT

              if (nextExists === true)
              {

                  showCounter = false     

                  // var potentialStreamers = potentialStreamers || []

                  // if (potentialStreamers.length <= 2)
                  // {
                  //   var potentialStreamers = map_users.slice();
                  // }

                  have_streamed.push(streamId)
                
                  // if diff returns 1 person (it's the upnext person) then empty have_streamed
                  if (map_users.diff(have_streamed).length <= 1)
                  {
                     have_streamed = []
                  }
                  
                  var potentialStreamers = (map_users.diff(have_streamed)).diff(no_stream); // temporary map_users instead of streamer_users

                  //potentialStreamers = potentialStreamers.filter(a => a !== streamId)

                  io.sockets.connected[streamId].emit("is_dead", streamRoom)

                  console.log("!DIED: " + streamRoom)

                  // store results in database
                  execPhp('store.php', function(error, php, outprint)
                  {
                    php.my_function(totalTime, streamId, payout, idToUser[streamId], function(err, result, output, printed)
                    {
                      console.log('!stored: ' + idToUser[streamId] + " " + payout)
                    });
                  });

                  streamId = upNextId

                  potentialStreamers = potentialStreamers.filter(a => a !== streamId)

                  io.sockets.connected[streamId].emit("is_live");

                  // tell everybody what the new room is

                  io.sockets.emit('new_room', streamRoom)

                  // no streamers availaible (create new room with clip saying no streamers)
                  if (potentialStreamers.length < 1)
                  {
                    upNextId = getKeyByValue(idToUser, "vojtadrmota")

                    if (upNextId == null)
                    {
                      upNextId = getKeyByValue(idToUser, "mschrage")
                    }
                  }
                  else
                  {
                    if (upnext_queue === true)
                    {
                      upNextId = queueupnext
                      upnext_queue = false
                    }
                    else
                    {
                      console.log("!POTENTIAL: " + potentialStreamers)
                      upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
                      upNextId = potentialStreamers.splice(upNext)[0];
                    }
                  }

                  // CHANGED: check if person upnext is still connected

                  if (upNextId == null || !map_users.includes(upNextId))
                  {
                    upNextId = getKeyByValue(idToUser, "vojtadrmota")

                    if (upNextId == null)
                    {
                      upNextId = getKeyByValue(idToUser, "mschrage")
                    }
                  }

                  io.sockets.connected[upNextId].emit("up_next");

                  totalTime = 0
                  voteCounter = 0

                  // hide counter for 5 sec here
                  setTimeout(function()
                    { 
                      counter = INTERVAL
                      showCounter = true
                    }, 3000);

              }
              else
              {
                // genesis hasn't been called yet
                //console.log('GENESIS NOT CALLED')
              }
          }

          // reset upvotes
          have_upvoted = []

        console.log("[!END_ANALYTICS!]")
          
        }
        else
        {
          counter--;
        }

}, 1000);

app.get('/cpanel', function(req, res) 
{

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

// gets a new up-next person

app.get('/next', function(req, res) 
{

  var potentialStreamers = map_users.slice(); // temporary

  potentialStreamers = potentialStreamers.filter(a => a !== streamId)
  potentialStreamers = potentialStreamers.filter(a => a !== upNextId)

  io.sockets.connected[upNextId].emit("is_dead", streamRoom)

  //io.sockets.connected[upNextId].emit('new_room', streamRoom)

  upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
  upNextId = potentialStreamers.splice(upNext)[0];

  io.sockets.connected[upNextId].emit("up_next");

  setTimeout(myFunction2, 3000);

  function myFunction2(){

    res.render("panel.html", { streaming: idToRoom[upNextId], threshold: threshold });

  }
})

// promotes up-next to broadcaster and re-runs lottery

app.get('/promote', function(req, res) 
{

    var potentialStreamers = map_users.slice(); // temporary

    potentialStreamers = potentialStreamers.filter(a => a !== streamId)

    var prevStreamerId = streamId
    io.sockets.connected[streamId].emit("is_dead", streamRoom)

    // store results in database
    execPhp('store.php', function(error, php, outprint)
    {
      php.my_function(totalTime, streamId, PAYOUT, idToUser[streamId], function(err, result, output, printed)
      {
        console.log('stored')
      });
    });

    streamId = upNextId

    potentialStreamers = potentialStreamers.filter(a => a !== streamId)

    io.sockets.connected[streamId].emit("is_live");

    // tell everybody what the new room is
    io.sockets.emit('new_room', streamRoom)

    if (upnext_queue === true)
    {
      upNextId = queueupnext
      upnext_queue = false
    }
    else
    {
      upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
      upNextId = potentialStreamers.splice(upNext)[0];
    }
    
    io.sockets.connected[upNextId].emit("up_next");

    totalTime = 0
    voteCounter = 0
    counter = INTERVAL

    setTimeout(myFunction3, 3000);

    function myFunction3(){

      res.render("panel.html", { streaming: idToRoom[upNextId], threshold: threshold });

    }

})

app.get('/addvotes', function(req, res) 
{

  var votes = parseInt(req.query.votes)

  for (var i = 0; i < votes; i++)
  {
    console.log('upvote:', idToRoom[streamId])
    voteCounter++

    io.sockets.emit('upvote')
    setTimeout(myFunction4, 600);

    function myFunction4(){

    }
  }

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/addviewers', function(req, res) 
{

  oldAdditionalViewers = additionalViewers

  var viewers = parseInt(req.query.viewers)

  additionalViewers = viewers
  viewerCounter += additionalViewers - oldAdditionalViewers

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/threshold', function(req, res) 
{

  var newThreshold = parseFloat(req.query.threshold)

  threshold = newThreshold

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/message', function(req, res) 
{

  io.sockets.emit('message', req.query.message)

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/messageupnext', function(req, res) 
{

  io.sockets.connected[upNextId].emit('message', req.query.message)

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/end', function(req, res) 
{

  io.sockets.emit('is_dead', streamRoom)

  streamRoom = ""
  io.sockets.emit('terminate', session)

  liveRoom = ""

  res.send("It's done, it's over :)")

})

app.get('/video', function(req, res) 
{

liveRoom = "thefameshow44"
streamRoom = "thefameshow44"

io.sockets.emit('start_show', liveRoom, VERSION)

setTimeout(myFunction9, 5000);

    function myFunction9(){

var yourscript = exec('sh video.sh '+req.query.video+' '+liveRoom,
        (error, stdout, stderr) => {
            console.log(`${stdout}`);
            console.log(`${stderr}`);
            if (error !== null) {
                console.log(`exec error: ${error}`);
            }
        });

  }
  
  //rooms["thefameshow44"] = {"title": "thefameshow44", "key": "thefameshow44"}

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/video_start', function(req, res) 
{

liveRoom = "thefameshow45"
streamRoom = "thefameshow45"

io.sockets.emit('new_room', liveRoom)

setTimeout(myFunction9, 5000);

    function myFunction9(){

var yourscript = exec('sh video.sh '+req.query.video+' '+liveRoom,
        (error, stdout, stderr) => {
            console.log(`${stdout}`);
            console.log(`${stderr}`);
            if (error !== null) {
                console.log(`exec error: ${error}`);
            }
        });

  }
  
  //rooms["thefameshow44"] = {"title": "thefameshow44", "key": "thefameshow44"}

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/video_schrage', function(req, res) 
{

liveRoom = "thefameshow46"
streamRoom = "thefameshow46"

io.sockets.emit('new_room', liveRoom)

setTimeout(myFunction9, 3000);

    function myFunction9(){

var yourscript = exec('sh video.sh '+req.query.video+' '+liveRoom,
        (error, stdout, stderr) => {
            console.log(`${stdout}`);
            console.log(`${stderr}`);
            if (error !== null) {
                console.log(`exec error: ${error}`);
            }
        });

  }
  
  //rooms["thefameshow44"] = {"title": "thefameshow44", "key": "thefameshow44"}

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/fake_comment', function(req, res) 
{

  commentdata = {'text': req.query.comment, 'key': "asdfk"}

  io.sockets.emit('comment', commentdata, req.query.username)  

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/genesisupnext', function(req, res) 
{

  var potentialStreamers = map_users.slice(); // temporary

  upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
  upNextId = potentialStreamers.splice(upNext)[0];

  io.sockets.connected[upNextId].emit("up_next");

  setTimeout(myFunction6, 3000);

  function myFunction6(){

    res.render("panel.html", { streaming: idToRoom[upNextId], threshold: threshold });

  }

})

app.get('/genesisupnext_vojta', function(req, res) 
{

  upNextId = getKeyByValue(idToUser, "vojtadrmota")

  io.sockets.connected[upNextId].emit("up_next");

  setTimeout(myFunction6, 3000);

  function myFunction6(){

    res.render("panel.html", { streaming: idToRoom[upNextId], threshold: threshold });

  }

})

app.get('/genesisupnext_matt', function(req, res) 
{

  upNextId = getKeyByValue(idToUser, "mschrage")

  io.sockets.connected[upNextId].emit("up_next");

  console.log("Genesis, Upnext: Matt")

  setTimeout(myFunction6, 3000);

  function myFunction6(){

    res.render("panel.html", { streaming: idToRoom[upNextId], threshold: threshold });

  }

})

app.get('/genesisstart', function(req, res) 
{

    console.log("[!BEGIN_SHOW!]")

    is_genesis = true

    nextExists = true

    var potentialStreamers = map_users.slice(); // temporary

    console.log("Genesis, upnext: "+upNextId)

    streamId = upNextId

    console.log("Genesis, streamid: "+streamId)

    potentialStreamers = potentialStreamers.filter(a => a !== streamId)

    io.sockets.connected[streamId].emit("is_live");

    // tell everybody what the new room is
    io.sockets.emit('new_room', streamRoom)

    if (upnext_queue === true)
    {
      upNextId = queueupnext
      upnext_queue = false
    }
    else
    {
      upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
      upNextId = potentialStreamers.splice(upNext)[0];
    }

    io.sockets.connected[upNextId].emit("up_next");

    totalTime = 0
    voteCounter = 0

                // hid counter for 5 sec here
                  showCounter = false
                  setTimeout(function()
                    { 
                      counter = INTERVAL
                      showCounter = true
                    }, 3000);

    setTimeout(myFunction3, 3000);

    function myFunction3(){

      res.render("panel.html", { streaming: idToRoom[upNextId], threshold: threshold });

    }

})

app.get('/intervideo', function(req, res) 
{

  // 500ms before counter hits 0
  var timeleft = counter * 1000 - 500

  var length = parseInt(req.query.length) * 1000

  setTimeout(myFunction7, timeleft);

  function myFunction7(){

    if (percentage >= 1)
    {
      // person is still on
      res.send("Person got more time. <a href='http://fameshow.co:3000/cpanel'>Go back to cPanel</a>.")
    }
    else
    {

      io.sockets.connected[upNextId].emit('message', "The streamer was given more time. Your turn soon!")

      counter = INTERVAL // make sure this is longer than the length of video
      //showCounter = false

      randnum = parseInt(Math.random() * 1000)
      roomname = "thefameshow44" + randnum

      io.sockets.connected[streamId].emit("is_dead", streamRoom)

      var yourscript = exec('sh video.sh '+req.query.video+' '+roomname,
        (error, stdout, stderr) => {
            console.log(`${stdout}`);
            console.log(`${stderr}`);
            if (error !== null) {
                console.log(`exec error: ${error}`);
            }
        });

      io.sockets.emit('new_room', roomname)

      setTimeout(myFunction8, length);

      function myFunction8(){

                var potentialStreamers = map_users.slice();

                streamId = upNextId

                potentialStreamers = potentialStreamers.filter(a => a !== streamId)

                io.sockets.connected[streamId].emit("is_live");

                // tell everybody what the new room is
                io.sockets.emit('new_room', streamRoom)

                if (upnext_queue === true)
                {
                  upNextId = queueupnext
                  upnext_queue = false
                }
                else
                {
                  upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
                  upNextId = potentialStreamers.splice(upNext)[0];
                }

                io.sockets.connected[upNextId].emit("up_next");

                totalTime = 0
                counter = INTERVAL
                percentage = 0
                showCounter = true

                res.send("Done. <a href='http://fameshow.co:3000/cpanel'>Go back to cPanel</a>.")

      }

    }

  }

})

app.get('/seeconnections', function(req, res) 
{

  var connected_users = ""
  var connected_size = 0
  var user_status = ""
  var user_selection = ""

  if (upnext_queue)
  {
    user_selection = "(manual)"
  }
  else
  {
    user_selection = "(automatic)"
  }

  for (var key in idToUser) {

    if (have_streamed.includes(key))
    {
      user_status = "<b>"+idToUser[key]+"</b>"
    }
    else
    {
      user_status = idToUser[key]
    }

    connected_users += "<br>"+user_status+": "+key+ " "+"<form method='GET' action='http://44.fameshow.co:3000/queueupnext'><input name='upnext' type='hidden' value='"+key+"' /><input type='submit' value='UpNext' /></form>"
    connected_size += 1
  }

  res.send("Current streamer: "+idToUser[streamId]+"<br> Upnext: "+idToUser[upNextId]+" "+user_selection+"<br><h1>Connected Users</h1> #: "+connected_size+" " + connected_users + "<h1>Broadcasters</h1> #: "+streamer_users.length+"<br>" + streamer_users)

})

app.get('/queueupnext', function(req, res) 
{

  queueupnext = req.query.upnext
  upnext_queue = true

  res.send("Done!")

})

app.get('/mbps', function(req, res) 
{

  res.send(idToMbps)

})

app.get('/confetti', function(req, res) 
{

  emoji = req.query.emoji

  io.sockets.emit('confetti', emoji)

  console.log(emoji)

  setTimeout(myFunction6, 3000);

  function myFunction6(){

    res.render("panel.html", { streaming: idToRoom[upNextId], threshold: threshold });

  }

})

app.get('/start', function(req, res) 
{

  // start intro
  liveRoom = "thefameshow44"
  streamRoom = "thefameshow44"

  io.sockets.emit('start_show', liveRoom)

  setTimeout(myFunction44, 5000);

    function myFunction44(){

  var yourscript = exec('sh video.sh intro.mp4',
        (error, stdout, stderr) => {
            console.log(`${stdout}`);
            console.log(`${stderr}`);
            if (error !== null) {
                console.log(`exec error: ${error}`);
            }
        });

  }

  // get first upnext

  setTimeout(myFunction43, 5000);

    function myFunction43(){

      upNextId = getKeyByValue(idToUser, "vojtadrmota")

      if (upNextId == null)
      {
        upNextId = getKeyByValue(idToUser, "mschrage")
      }

      io.sockets.connected[upNextId].emit("up_next");

    }

  // run genesis

  setTimeout(myFunction42, 18000);

    function myFunction42(){

       nextExists = true

    var potentialStreamers = map_users.slice(); // temporary

    streamId = upNextId

    potentialStreamers = potentialStreamers.filter(a => a !== streamId)

    io.sockets.connected[streamId].emit("is_live");

    // tell everybody what the new room is
    io.sockets.emit('new_room', streamRoom)

    upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
    upNextId = potentialStreamers.splice(upNext)[0];

    io.sockets.connected[upNextId].emit("up_next");

    totalTime = 0
    voteCounter = 0

    // hid counter for 5 sec here
    showCounter = false
    setTimeout(function()
      { 
        counter = INTERVAL
        showCounter = true
      }, 3000);
      
    }

    res.send("Show started!")

})

console.log('listening on port 3000...')