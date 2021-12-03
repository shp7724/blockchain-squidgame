const scene = new THREE.Scene()
const camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 )

const renderer = new THREE.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )
document.body.appendChild( renderer.domElement )

const light = new THREE.AmbientLight( 0xffffff )
scene.add( light )

const directionalLight = new THREE.DirectionalLight( 0xffffff, 0.3 );
directionalLight.castShadow = true
scene.add( directionalLight )
directionalLight.position.set( 0, 1, 1 )

camera.position.z = 5
renderer.setClearColor( 0xedd08b, 1)

const loader = new THREE.GLTFLoader()
let doll

const start_position = 6
const end_position = -start_position

const text = document.querySelector('#main-title')
const timer = document.querySelector('.timer')
const box = document.querySelector('.message_content')

let DEAD_PLAYERS = 0
let SAFE_PLAYERS = 0

// 타이머 흐르는 여부
var running = 0;
// 타이머 id
var timerId = 0;
// 0.001초 단위
var time = 0;

// 무궁화 박스 가로 길이
let width = box.offsetWidth;

const startBtn = document.querySelector('#start-btn')

//musics
const bgMusic = new Audio('./music/bg.mp3')
bgMusic.loop = true
const winMusic = new Audio('./music/win.mp3')
const loseMusic = new Audio('./music/lose.mp3')

loader.load( './model/scene.gltf', function ( gltf ){
    scene.add( gltf.scene )
    doll = gltf.scene
    gltf.scene.position.set(-5,-1, 0)
    gltf.scene.scale.set(0.4, 0.4, 0.4)
    startBtn.innerText = "베팅 및 게임 시작"
})

// 회전 속도 랜덤 및 판정 수정
function lookBackward(rotateDuration){
    gsap.to(doll.rotation, {duration: rotateDuration, y: -1.575})
    setTimeout(() => dallFacingBack = true, 150)
}
function lookForward(rotateDuration){
    gsap.to(doll.rotation, {duration: rotateDuration, y: 1.575})
    setTimeout(() => dallFacingBack = false, rotateDuration * 1000)
}

function createCube(size, posX, rotY = 0, color = 0xfbc851){
    const geometry = new THREE.BoxGeometry( size.w, size.h, size.d )
    const material = new THREE.MeshBasicMaterial( { color } )
    const cube = new THREE.Mesh( geometry, material )
    cube.position.set(posX, 0, 0)
    cube.rotation.y = rotY
    scene.add( cube )
    return cube
}

//Creating runway
// createCube({w: start_position * 2 + .21, h: 1.5, d: 1}, 0, 0, 0xe5a716).position.z = -1
// createCube({w: .2, h: 1.5, d: 1}, start_position, -.4)
// createCube({w: .2, h: 1.5, d: 1}, end_position, .4)


class Player {
    constructor(name = "Player", radius = .25, posY = 0, color = 0xffffff){
        const geometry = new THREE.SphereGeometry( radius, 100, 100 )
        const material = new THREE.MeshBasicMaterial( { color } )
        const player = new THREE.Mesh( geometry, material )
        scene.add( player )
        player.position.x = start_position - .4
        player.position.z = 1
        player.position.y = posY
        this.player = player
        this.playerInfo = {
            positionX: start_position - .4,
            velocity: 0,
            name,
            isDead: false
        }
    }

    run(){
        if(this.playerInfo.isDead) return
        // 플레이어 속도 조절
        this.playerInfo.velocity = .015
    }

    stop(){
        gsap.to(this.playerInfo, { duration: .1, velocity: 0 })
    }

    check(){
        if(this.playerInfo.isDead) return
        if(!dallFacingBack && this.playerInfo.velocity > 0){
            text.innerText = this.playerInfo.name + " lost!!!"
            this.playerInfo.isDead = true
            this.stop()
            DEAD_PLAYERS++
            loseMusic.play()
            if(DEAD_PLAYERS == players.length){
                text.innerText = "456번, 탈락."
                gameStat = "ended"
            }
            if(DEAD_PLAYERS + SAFE_PLAYERS == players.length){
                gameStat = "ended"
            }
        }
        if(this.playerInfo.positionX < end_position + .7){
            text.innerText = this.playerInfo.name + "456번, 성공."
            this.playerInfo.isDead = true
            this.stop()
            SAFE_PLAYERS++
            winMusic.play()
            if(SAFE_PLAYERS == players.length){
                text.innerText = "456번, 성공."
                gameStat = "ended"
                playerCompletes(time * 1000)
            }
            if(DEAD_PLAYERS + SAFE_PLAYERS == players.length){
                gameStat = "ended"
            }
        }
        // 어떤 방식으로든 게임이 종료되면 타이머가 멈춘다.
        if (gameStat == "ended") {
            running = 0;
        }
    }

    update(){
        this.check()
        this.playerInfo.positionX -= this.playerInfo.velocity
        this.player.position.x = this.playerInfo.positionX
    }
}

async function delay(ms){
    return new Promise(resolve => setTimeout(resolve, ms))
}

// player2 삭제
const player1 = new Player("Player 1", .25, -2, 0x006e64)

const players = [
    {
        player: player1,
        key: "ArrowLeft",
        name: "Player 1"
    },
    // player2 삭제
]

// 시간 제한 3분으로 늘리기
const TIME_LIMIT = 180
async function init(){
    // text.style.width = '40%';
    await delay(500)
    // 초 세기 시작
    running = 1;
    increment()
    // 배경음악 시끄러워서 끔
    // bgMusic.play()
    start()
}

let gameStat = "loading"

function start(){
    gameStat = "started"
    // const progressBar = createCube({w: 8, h: .1, d: 1}, 0, 0, 0xebaa12)
    // progressBar.position.y = 3.35
    // gsap.to(progressBar.scale, {duration: TIME_LIMIT, x: 0, ease: "none"})
    setTimeout(() => {
        if(gameStat != "ended"){
            running = 0
            text.innerText = "시간 초과!"
            loseMusic.play()
            gameStat = "ended"
        }
    }, TIME_LIMIT * 1000)
    startDall()
}

function increment() {
    if (running == 1) {
        timerId = setTimeout(function () {
            time++;
            var mins = Math.floor(time / 100 / 60);
            var secs = Math.floor(time / 100 % 60);
            var milSecs = time % 100;
            if (mins < 10) {
                mins = "0" + mins;
            }
            if (secs < 10) {
                secs = "0" + secs;
            }
            // if (milSecs < 10) {
            //     milSecs = "00" + milSecs;
            if (milSecs < 10) {
                milSecs = "0" + milSecs;
            }

            timer.innerText = mins + ":" + secs + ":" + milSecs;
            increment();
        }, 10)
    }
}

let dallFacingBack = true
var defaultRotateDuration = 1
var firstRotate = 1
var secondRotate = 1
var backwardDelay = 1
var forwardDelay = 1
var totalDelay = 1

var maxDelay = 3000 + 60
var curDelay = 0

async function startDall(){
    // 돌아보기 사이의 시간 텀은 랜덤으로 되어있음
    // 돌아보는데 걸리는 시간도 랜덤화 한다.
    defaultRotateDuration = .10
    firstRotate = multipleBy10((defaultRotateDuration + Math.random() * .50) * 1000)
    secondRotate = multipleBy10((defaultRotateDuration + Math.random() * .50) * 1000)
    backwardDelay = multipleBy10((Math.random() * 1500) + 1500)
    forwardDelay = multipleBy10((Math.random() * 750) + 750)
    totalDelay = firstRotate + secondRotate + backwardDelay + forwardDelay

   lookBackward(firstRotate / 1000)
    updateMessageBackward()
   await delay(backwardDelay)

    let depth = secondRotate / 10
    let timePerDepth = (maxDelay - curDelay) / depth
    updateMessageRotating(timePerDepth)
    lookForward(secondRotate / 1000)

   await delay(forwardDelay)
    curDelay = 0
    box.style.width = "0px"
   startDall()
}

function multipleBy10(number) {
    return number - number % 10
}

function updateMessageBackward() {
    if (curDelay < backwardDelay && gameStat != "ended") {
        setTimeout(function () {
            curDelay = curDelay + 10;
            box.style.width = width * (curDelay / maxDelay) + "px";
            updateMessageBackward();
        }, 10)
    }
}

function updateMessageRotating(timePerDepth) {
    if (curDelay < maxDelay && gameStat != "ended") {
        setTimeout(function () {
            curDelay = curDelay + timePerDepth;
            box.style.width = width * (curDelay / maxDelay) + "px";
            updateMessageRotating(timePerDepth);
        }, 10)
    }
}



function animate(){
    renderer.render( scene, camera )
    players.map(player => player.player.update())
    if(gameStat == "ended") return
    requestAnimationFrame( animate )
}
animate()

window.addEventListener( "keydown", function(e){
    if(gameStat != "started") return
    let p = players.find(player => player.key == e.key)
    if(p){
        p.player.run()
    }
})
window.addEventListener( "keyup", function(e){
    let p = players.find(player => player.key == e.key)
    if(p){
        p.player.stop()
    }
})

window.addEventListener( 'resize', onWindowResize, false )
function onWindowResize(){
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()
    renderer.setSize( window.innerWidth, window.innerHeight )
}