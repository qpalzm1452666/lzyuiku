-- JBS UI library v3.2 standalone. Evaluating this file returns an API; it creates no window.
-- 兼容 CreateWindow / Tab / 各类控件 / Notify 的调用方式。

local function loadLibrary()
local environment=(type(getgenv)=="function" and getgenv()) or _G
local KEY="__JBSMetalLibraryV32"
local cached=environment[KEY]
if cached then
 assert(cached.Version=="3.2", "JBS 库版本冲突，请重新进入游戏")
 return cached
end
local Library={Version="3.2",GameState="idle"}
local instance,window
local function currentGui()
 local player=game:GetService("Players").LocalPlayer
 assert(player,"JBS 必须在游戏客户端运行")
 return player:WaitForChild("PlayerGui")
end
local function legacyConflict()
 local roots={currentGui()}
 local ok,core=pcall(function() return game:GetService("CoreGui") end)
 if ok and core then roots[#roots+1]=core end
 for _,root in ipairs(roots) do
  for _,node in ipairs(root:GetDescendants()) do
   if node:IsA("ScreenGui") and (node.Name=="JBS_91_78_Showcase" or (node.Name=="JBS_Metal_v31" and not (instance and instance:IsAlive()))) then return node.Name end
   if node:IsA("TextLabel") or node:IsA("TextButton") then
    local text=node.Text or ""
    if text=="JBS 鸡巴骚" or text=="JBS鸡巴骚" or text=="JBS 力量传奇 · 金属版" then return text end
   end
  end
 end
 if Library.GameState=="idle" then
  for _,key in ipairs({"auto_train","auto_rebirth","auto_wheel","auto_petbuy","auto_packrebirth","auto_eategg","auto_fasttrain","auto_boss"}) do
   if rawget(_G,key)~=nil then return "旧版 JBS 功能状态" end
  end
 end
end
local function checkLegacy()
 local conflict=legacyConflict()
 assert(not conflict,"检测到旧 JBS（"..tostring(conflict).."）。请退出并重新进入游戏，只运行新版启动文件；不要同时运行原脚本或旧 UI。")
end
local function createRenderer()
-- JBS 91&78 · native pink-purple metal grille
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
assert(player, "请在客户端 LocalScript 中运行")
local playerGui = player:WaitForChild("PlayerGui")
local previous = playerGui:FindFirstChild("JBS_Metal_v31")
assert(not previous, "JBS 已在运行")
local scene = {version="metal-grid-2", width=1016, height=726, palette={base="#16091F", panel="#251033", pink="#FF4FD8", violet="#A855F7", pearl="#D8B4FE", white="#FFE6FA"}, pattern={pitchX=42, pitchY=28, size=13}, navigation={{id="main", label="主要", icon="bolt"}, {id="travel", label="传送", icon="pin"}, {id="pets", label="宠物", icon="pet"}, {id="boss", label="Boss", icon="crown"}, {id="pack", label="换包重生", icon="weight"}}, features={}}
local colorCache={}
local function rgb(hex)
 if not colorCache[hex] then colorCache[hex]=Color3.fromHex(hex:gsub("#", "")) end
 return colorCache[hex]
end
local P = scene.palette
local WHITE = Color3.new(1,1,1)
local function make(class, properties, parent)
 local object = Instance.new(class)
 for key, value in pairs(properties) do object[key] = value end
 object.Parent = parent
 return object
end
local function corner(object, radius) make("UICorner", {CornerRadius=UDim.new(0,radius)}, object) end
local function gradient(object, stops, rotation)
 local keys = {}
 for _, stop in ipairs(stops) do keys[#keys+1] = ColorSequenceKeypoint.new(stop[1],rgb(stop[2])) end
 return make("UIGradient",{Color=ColorSequence.new(keys),Rotation=rotation or 0},object)
end
local function stroke(object, color, thickness, transparency)
 return make("UIStroke",{Color=rgb(color),Thickness=thickness or 1,Transparency=transparency or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},object)
end
local function frame(parent,name,x,y,w,h,color,r,z,alpha)
 local o=make("Frame",{Name=name,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=rgb(color or P.base),BackgroundTransparency=alpha or 0,BorderSizePixel=0,Active=false,ZIndex=z or 1},parent)
 if r then corner(o,r) end
 return o
end
local function label(parent,name,text,x,y,w,h,size,color,bold,z)
 return make("TextLabel",{Name=name,Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,BorderSizePixel=0,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,TextSize=(size>=18 or name=="Tribe" or name=="JBSMetalMark" or name=="Text") and size or math.floor(size*1.4+.5),TextColor3=rgb(color or P.white),TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=false,Active=false,Selectable=false,ZIndex=z or 5},parent)
end
local function button(parent,name,x,y,w,h,r)
 local b=make("TextButton",{Name=name,Text="",Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Selectable=true,ClipsDescendants=true,ZIndex=5},parent)
 if r then corner(b,r) end
 return b
end
local connections, tweens, temporaries = {}, {}, {}
local destroyed=false
local function connect(event,callback)
 local c=event:Connect(callback);connections[#connections+1]=c;return c
end
local function tween(object, properties, duration, delay)
 local t=TweenService:Create(object,TweenInfo.new(duration or .22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,delay or 0),properties)
 tweens[t]=true
 t.Completed:Once(function() tweens[t]=nil end)
 t:Play();return t
end
local gui=make("ScreenGui",{Name="JBS_Metal_v31",ResetOnSpawn=false,DisplayOrder=30,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},playerGui)
gui:SetAttribute("JBSLibraryVersion","3.2")
local viewport=frame(gui,"Viewport",0,0,0,0,P.base,nil,1,1)
viewport.Size=UDim2.fromScale(1,1)
local canvas=frame(viewport,"ReferenceCanvas",0,0,1016,726,P.base,nil,1,1)
canvas.Position=UDim2.fromScale(.5,.5);canvas.AnchorPoint=Vector2.new(.5,.5)
local scale=make("UIScale",{Scale=1},canvas)
local expanded=false
local function fit()
 local size=viewport.AbsoluteSize
 scale.Scale=math.max(.05,math.min((size.X-44)/1016,(size.Y-44)/726,expanded and 1.6 or 1.2))
end
connect(viewport:GetPropertyChangedSignal("AbsoluteSize"),fit);fit()
local shell=make("Frame",{Name="Window",Size=UDim2.fromOffset(1016,726),BackgroundColor3=WHITE,BorderSizePixel=0,ClipsDescendants=true,ZIndex=2},canvas)
corner(shell,28)
local shellMetal=gradient(shell,{{0,"#64245D"},{.3,P.panel},{.58,P.base},{1,"#572476"}},30)
local rim=stroke(shell,P.white,1.5,.08)
local metalStops={{0,"#8B439F"},{.28,P.pink},{.43,P.pearl},{.49,P.white},{.53,"#562168"},{.7,P.violet},{1,"#D777D1"}}
local rimGradient=gradient(rim,metalStops,25)
local glows={}
for i,thickness in ipairs({16,9,4}) do
 local g=frame(canvas,"AmbientRim"..i,0,0,1016,726,P.base,28,1,1)
 local s=stroke(g,P.pink,thickness,.96-i*.025)
 glows[#glows+1]={object=g,stroke=s}
end
local inner=frame(shell,"InnerEdge",5,5,1006,716,P.base,23,2,1);stroke(inner,P.pearl,1,.78)
local headerLine=frame(shell,"HeaderLine",28,93,960,1,P.pearl,nil,3,.82)
local logo=label(shell,"HeaderJBS","JBS",28,21,89,52,43,P.white,true)
logo.TextColor3=WHITE
local logoGradient=gradient(logo,{{0,"#B36DCC"},{.25,P.pink},{.41,P.pearl},{.47,P.white},{.51,"#642075"},{.66,"#F38CD9"},{1,P.pearl}},15)
label(shell,"Title","JBS 力量传奇",135,24,320,26,20,P.white,true)
label(shell,"Tribe","部落 ID · 91&78",135,53,300,19,12,P.pearl)
for i=0,15 do
 local slat=frame(shell,"HeaderMetal",618+i*12,27,1,39,P.pearl,nil,3,.62)
 gradient(slat,{{0,"#69256C"},{.43,P.pink},{.5,P.white},{.59,"#713087"},{1,P.pearl}},75)
end
local minimize=button(shell,"Minimize",858,28,32,32,8)
local expand=button(shell,"Expand",902,28,32,32,8)
local close=button(shell,"Close",946,28,32,32,8)
label(minimize,"Glyph","—",6,0,26,30,20,P.pearl)
label(expand,"Glyph","□",7,0,26,30,22,P.pearl)
label(close,"Glyph","×",8,0,24,30,26,P.pearl)
local side=frame(shell,"Sidebar",13,94,350,619,P.panel,18,3,1)
local content=frame(shell,"Content",375,94,628,619,P.panel,18,3)
content.BackgroundColor3=WHITE;content.ClipsDescendants=true
local contentMetal=gradient(content,{{0,"#74286D"},{.45,"#2C103F"},{1,"#5D257C"}},34)
stroke(content,P.pearl,1,.38)
local glyphs={}
local prototype=label(nil,"JBSMetalMark","JBS",0,0,29,17,scene.pattern.size,P.white,true,2)
prototype.TextColor3=WHITE
local protoGradient=gradient(prototype,{{0,"#A663BB"},{.27,"#F4AFE2"},{.42,P.white},{.49,"#7A398F"},{.67,"#BD76DE"},{1,"#EC97D6"}},90)
local function pattern(parent,w,h,opacity)
 local material=frame(parent,"BrandMaterial",0,0,w,h,P.base,nil,1,1)
 material.ClipsDescendants=true
 for row=0,math.floor((h-30)/28) do
  local y=12+row*28
  for col=0,math.floor(w/42) do
   local x=12+col*42+(row%2)*21
   if x+29<w-12 then
    local glyph=prototype:Clone();glyph.Position=UDim2.fromOffset(x,y);glyph.TextTransparency=1-opacity;glyph.Parent=material
    glyphs[#glyphs+1]={object=glyph,x=x,y=y,width=w,base=opacity}
   end
  end
 end
end
pattern(side,350,619,.29);pattern(content,628,619,.65);prototype:Destroy()
local searchMaterial=frame(side,"SearchMaterial",8,0,334,70,P.white,17,4)
searchMaterial.BackgroundColor3=WHITE
gradient(searchMaterial,{{0,"#542354"},{1,P.panel}},25)
stroke(searchMaterial,P.pearl,1,.55)
local search=make("TextBox",{Name="Search",PlaceholderText="搜索功能",Text="",ClearTextOnFocus=false,Position=UDim2.fromOffset(8,0),Size=UDim2.fromOffset(334,70),BackgroundTransparency=1,BackgroundColor3=WHITE,BorderSizePixel=0,TextColor3=rgb(P.white),PlaceholderColor3=rgb(P.pearl),Font=Enum.Font.Gotham,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},side)
corner(search,17)
make("UIPadding",{PaddingLeft=UDim.new(0,24),PaddingRight=UDim.new(0,18)},search)
for i=1,#scene.navigation do
 local backing=frame(side,"NavigationBacking",8,90+(i-1)*72,334,57,P.panel,12,3,.08)
end
local selection=frame(side,"SelectedNavigation",8,90,334,57,P.white,12,4)
selection.BackgroundColor3=WHITE;gradient(selection,{{0,"#E73CBD"},{.7,P.violet},{1,"#7F33D0"}},15);stroke(selection,P.white,1,.48)
local selectionGlow=frame(selection,"LightStrip",0,15,3,26,P.white,2,5)
local menuButtons={}
local function line(parent,x1,y1,x2,y2,color,width)
 local dx,dy=x2-x1,y2-y1
 local o=frame(parent,"IconStroke",(x1+x2)/2,(y1+y2)/2,math.sqrt(dx*dx+dy*dy),width or 1.6,color,1,6)
 o.AnchorPoint=Vector2.new(.5,.5);o.Rotation=math.deg(math.atan2(dy,dx));return o
end
local function icon(parent,kind,x,y)
 local p=frame(parent,"Icon",x,y,24,24,P.base,nil,6,1)
 local paths={bolt={{13,2,4,14},{4,14,11,14},{11,14,10,22},{10,22,20,9},{20,9,13,9},{13,9,13,2}},weight={{7,12,17,12},{4,7,4,17},{7,5,7,19},{17,5,17,19},{20,7,20,17}},pin={{4,9,12,3},{12,3,20,9},{20,9,18,15},{18,15,12,22},{12,22,6,15},{6,15,4,9}},pet={{4,9,3,3},{3,3,9,6},{9,6,15,6},{15,6,21,3},{21,3,20,16},{20,16,16,20},{16,20,8,20},{8,20,4,16},{4,16,4,9},{8,12,8,13},{16,12,16,13},{10,16,12,18},{12,18,14,16}},crown={{3,6,8,11},{8,11,12,3},{12,3,16,11},{16,11,21,6},{21,6,19,19},{19,19,5,19},{5,19,3,6},{6,16,18,16}},spark={{12,2,15,9},{15,9,22,12},{22,12,15,15},{15,15,12,22},{12,22,9,15},{9,15,2,12},{2,12,9,9},{9,9,12,2}}}
 for _,v in ipairs(paths[kind] or paths.spark) do line(p,v[1],v[2],v[3],v[4],P.pearl) end
 return p
end
for i,item in ipairs(scene.navigation) do
 local b=button(side,item.id,8,90+(i-1)*72,334,57,12)
 icon(b,item.icon,24,16)
 local title=label(b,"Label",item.label,68,0,210,57,19,P.pearl)
 label(b,"Index",string.format("%02d",i),299,0,27,57,11,P.pearl)
 menuButtons[i]={button=b,title=title,item=item}
end
frame(side,"SignatureRule",24,505,302,1,P.pearl,nil,4,.7)
local sideLogo=label(side,"SideJBS","JBS",24,524,140,50,45,P.white,true)
sideLogo.TextColor3=WHITE
local sideLogoGradient=gradient(sideLogo,metalStops,20)
local signatureSubtitle=label(side,"SignatureSubtitle","部落专属",24,576,84,18,11,P.pearl)
signatureSubtitle.TextXAlignment=Enum.TextXAlignment.Center
label(side,"IDs","91&78",219,548,105,39,25,P.white,true)
local titleGuard=frame(content,"TitleGuard",1,1,626,115,P.panel,17,3,.02)
make("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.35,0),NumberSequenceKeypoint.new(.65,.8),NumberSequenceKeypoint.new(1,1)})},titleGuard)
local pageTitle=label(content,"PageTitle","主要",26,23,325,35,25,P.white,true)
local description=label(content,"Description","功能列表",26,65,350,20,12,P.pearl)
local edition=frame(content,"Edition",474,26,127,33,P.white,7,4)
gradient(edition,{{0,"#AC4B9E"},{1,"#62288B"}},20);stroke(edition,P.pearl,1,.45)
label(edition,"EditionText","JBS · 91&78",12,0,106,33,12,P.white,true)
local list=make("Frame",{Name="Features",Position=UDim2.fromOffset(22,116),Size=UDim2.fromOffset(584,398),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5},content)
local footer=frame(content,"FooterShade",1,521,626,97,P.panel,nil,3,.13)
make("UIGradient",{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})},footer)
local dot=frame(content,"StatusLight",27,578,5,5,P.white,3,5);stroke(dot,P.pink,3,.72)
label(content,"Footer","JBS · 力量传奇",40,563,350,34,13,P.white,true)
label(content,"FooterIDs","91&78",530,563,85,34,14,P.white,true)
local stars={}
for i=1,16 do
 local x=28+(i*37)%570
 local y=i<=6 and 10+(i*7)%85 or 530+(i*13)%64
 local s=frame(content,"Spark",x,y,2,2,P.white,1,2,.5)
 stars[#stars+1]={object=s,phase=i*.77}
 if i%4==0 then
  for _,size in ipairs({{1,10},{10,1}}) do
   local ray=frame(s,"StarRay",1,1,size[1],size[2],P.white,nil,2,.3)
   ray.AnchorPoint=Vector2.new(.5,.5)
  end
 end
end
local notice=frame(shell,"ReadyNotice",410,620,570,90,P.white,12,15)
gradient(notice,{{0,"#852A77"},{1,"#3C185E"}},15);stroke(notice,P.pearl,1,.25)
label(notice,"Mark","JBS",17,10,66,44,26,P.white,true,16)
label(notice,"Ready","界面已就绪",95,10,450,25,15,P.white,true,16)
label(notice,"Details","91&78 · 金属印记",95,35,450,46,11,P.pearl,false,16)
notice.Details.TextWrapped=true
notice.Visible=false
local restore=button(viewport,"RestoreJBS",0,0,132,46,14)
restore.Position=UDim2.fromScale(.5,.5);restore.AnchorPoint=Vector2.new(.5,.5);restore.BackgroundTransparency=0;restore.BackgroundColor3=WHITE
stroke(restore,P.pearl,1,.2);gradient(restore,{{0,"#982A80"},{1,"#6539A3"}},20)
local restoreLabel=label(restore,"Text","JBS 鸡巴骚",0,0,132,46,16,P.white,true)
restoreLabel.TextXAlignment=Enum.TextXAlignment.Center
restore.Visible=false
local dragHandle=button(shell,"DragHandle",13,8,830,78)
local dragging,dragStart,dragStartPos
local restoreDragging,restoreMoved,restoreStart,restoreStartPos
connect(dragHandle.InputBegan,function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
  dragging=true;dragStart=input.Position;dragStartPos=canvas.Position
  input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
 end
end)
connect(restore.InputBegan,function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
  restoreDragging=true;restoreMoved=false;restoreStart=input.Position;restoreStartPos=restore.Position
  input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then restoreDragging=false end end)
 end
end)
connect(UserInputService.InputChanged,function(input)
 if not dragging and not restoreDragging then return end
 if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
 if dragging then
  local delta=input.Position-dragStart
  canvas.Position=UDim2.new(.5,dragStartPos.X.Offset+delta.X,.5,dragStartPos.Y.Offset+delta.Y)
 end
 if restoreDragging then
  local delta=input.Position-restoreStart
  if math.abs(delta.X)+math.abs(delta.Y)>8 then restoreMoved=true end
  restore.Position=UDim2.new(restoreStartPos.X.Scale,restoreStartPos.X.Offset+delta.X,restoreStartPos.Y.Scale,restoreStartPos.Y.Offset+delta.Y)
 end
end)
local actionEvent=make("BindableEvent",{Name="UISelectionChanged"},gui)
local scroll=make("ScrollingFrame",{Name="ControlScroll",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,0),ScrollBarThickness=5,ScrollBarImageColor3=rgb(P.pink),ScrollingDirection=Enum.ScrollingDirection.Y,Active=true,ZIndex=5},list)
local category="main"
local cards={}
local empty=label(scroll,"Empty","没有匹配的功能",4,4,564,70,15,P.pearl)
empty.TextXAlignment=Enum.TextXAlignment.Center;empty.Visible=false
local adapter,window={},{}
local toggleKeys={
 ["自动重生"]="auto_rebirth",["自动锻炼"]="auto_train",["自动轮盘"]="auto_wheel",
 ["自动购买"]="auto_petbuy",["自动打Boss"]="auto_boss",["换包重生"]="auto_packrebirth",
 ["快速锻炼"]="auto_fasttrain",["自动吃蛋"]="auto_eategg",
}
local displayNames={
 ["目标次数"]="自动重生 · 目标次数",["自动购买"]="自动购买宠物 / 光环",
 ["购买一次"]="购买所选宠物 / 光环",["悬停高度"]="Boss 悬停高度",
 ["送蛋"]="赠送蛋白蛋",["自动吃蛋"]="自动使用蛋白蛋",
 ["快速锻炼"]="快速锻炼",
}
local NOTICE_DURATION=3
local noticeToken,noticeDeadline=0,0
local progressTrack=frame(notice,"CountdownTrack",18,77,534,4,"#281034",2,16)
stroke(progressTrack,P.pearl,1,.75)
local progressFill=frame(progressTrack,"CountdownFill",0,0,534,4,P.white,2,17)
gradient(progressFill,{{0,P.pink},{.52,P.violet},{.86,P.pearl},{1,P.white}},0)
stroke(progressFill,P.pink,2,.55)
local countdown=label(notice,"Countdown","3.0s",488,9,64,23,11,P.pearl,false,17)
countdown.TextXAlignment=Enum.TextXAlignment.Right
notice.Ready.Size=UDim2.fromOffset(380,25)
notice.Details.Size=UDim2.fromOffset(450,34)
notice.Active=false
local function updateNoticeCountdown()
 if not notice.Visible then return end
 local remaining=math.max(0,noticeDeadline-os.clock())
 progressFill.Size=UDim2.fromScale(remaining/NOTICE_DURATION,1)
 countdown.Text=string.format("%.1fs",math.ceil(remaining*10)/10)
 if remaining<=0 then notice.Visible=false end
end
connect(RunService.Heartbeat,updateNoticeCountdown)
local function formatNoticeContent(content,title)
 local message=tostring(content or "")
 message=message:gsub("，无限", ""):gsub(",%s*无限", "")
 message=message:gsub("自动重生已开启", "自动重生以开始"):gsub("自动重生已开始", "自动重生以开始")
 local closed=string.find(tostring(title or ""),"已关闭",1,true) or string.find(message,"已关闭",1,true) or string.find(message,"已停止",1,true)
 message=message:gsub("%s*开🦌开🦌", ""):gsub("%s*🐍了🐍了", "")
 message=message..(closed and " 🐍了🐍了" or " 开🦌开🦌")
 return message
end
function adapter:Notify(options)
 if destroyed then return end
 noticeToken=noticeToken+1;local token=noticeToken
 noticeDeadline=os.clock()+NOTICE_DURATION
 gui:SetAttribute("NoticeSequence",noticeToken)
 notice.Ready.Text=tostring(options.Title or "JBS")
 notice.Details.Text=formatNoticeContent(options.Content,options.Title)
 progressFill.Size=UDim2.fromScale(1,1)
 countdown.Text="3.0s"
 notice.Visible=shell.Visible and gui.Enabled
 task.delay(NOTICE_DURATION,function()
  if not destroyed and token==noticeToken then
   progressFill.Size=UDim2.fromScale(0,1)
   countdown.Text="0.0s"
   notice.Visible=false
  end
 end)
 if not notice.Visible then
  pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=options.Title or "JBS",Text=notice.Details.Text,Duration=NOTICE_DURATION}) end)
 end
end
local function syncToggle(c)
 if c.kind~="Toggle" then return end
 local key=toggleKeys[c.originalTitle]
 if key then c.value=_G[key]==true end
 c.state.Text=c.busy and "处理中" or (c.value and "已开启" or "已关闭")
 c.track.BackgroundColor3=rgb(c.value and P.pink or "#5A3565")
 c.knob.Position=UDim2.fromOffset(c.value and 25 or 3,3)
 c.edge.Transparency=c.value and .12 or .6
 c.button:SetAttribute("Value",c.value)
end
local function invoke(c,value)
 if destroyed or c.busy then return end
 c.busy=true
 if c.kind=="Toggle" then syncToggle(c) end
 if c.kind=="Button" then c.state.Text="处理中…" end
 task.spawn(function()
  local ok,err=pcall(c.options.Callback or function() end,value)
  c.busy=false
  if destroyed then return end
  if c.kind=="Toggle" then syncToggle(c) end
  if c.kind=="Button" then c.state.Text="执行 ›" end
  if not ok then
   adapter:Notify({Title="操作未完成",Content=tostring(err),Duration=7})
   warn("[JBS Metal UI] "..tostring(err))
  end
 end)
end
local function filterCards(animate)
 local y,count=4,0;local q=string.lower(search.Text)
 for _,c in ipairs(cards) do
  local show=c.item.category==category and (q=="" or (c.kind~="Divider" and c.kind~="Section" and string.find(string.lower(c.item.label.." "..c.originalTitle),q,1,true)~=nil))
  c.button.Visible=show
  if show then
   c.y=y;c.button.Position=UDim2.fromOffset(4,y);y=y+c.height+8
   if c.kind~="Divider" and c.kind~="Section" then count=count+1 end
  end
 end
 scroll.CanvasSize=UDim2.fromOffset(0,y+6)
 empty.Visible=count==0;description.Text=(q~="" and "搜索结果" or "功能列表")
 if animate then
  scroll.CanvasPosition=Vector2.zero
  list.Position=UDim2.fromOffset(22,125);
  tween(list,{Position=UDim2.fromOffset(22,116),},.22)
 end
end
local popup=frame(shell,"DropdownModal",380,112,600,488,P.base,16,30,.02)
popup.Visible=false;stroke(popup,P.pink,1,.1)
local popupTitle=label(popup,"Title","选择",18,12,500,30,18,P.white,true,31)
local popupClose=button(popup,"CloseDropdown",552,10,32,32,8);popupClose.ZIndex=32
label(popupClose,"Glyph","×",4,0,28,32,24,P.white,false,33)
local popupSearch=make("TextBox",{Name="OptionSearch",Position=UDim2.fromOffset(18,52),Size=UDim2.fromOffset(564,40),BackgroundColor3=rgb(P.panel),BorderSizePixel=0,Text="",PlaceholderText="搜索选项",TextColor3=rgb(P.white),PlaceholderColor3=rgb(P.pearl),TextSize=22,Font=Enum.Font.Gotham,ClearTextOnFocus=false,ZIndex=31},popup)
corner(popupSearch,8)
local popupList=make("ScrollingFrame",{Name="Options",Position=UDim2.fromOffset(18,102),Size=UDim2.fromOffset(564,366),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,0),ScrollBarThickness=5,ScrollBarImageColor3=rgb(P.pink),ScrollingDirection=Enum.ScrollingDirection.Y,Active=true,ZIndex=31},popup)
local popupOwner,popupConnections=nil,{}
local function clearOptions()
 for _,c in ipairs(popupConnections) do c:Disconnect() end
 table.clear(popupConnections)
 for _,child in ipairs(popupList:GetChildren()) do child:Destroy() end
end
local function closePopup()
 popup.Visible=false;popupOwner=nil;clearOptions()
end
local drawOptions
local function openPopup(c)
 closePopup();popupOwner=c
 popupTitle.Text=c.item.label;popupSearch.Text="";popup.Visible=true
 popupList.CanvasPosition=Vector2.zero;drawOptions()
end
drawOptions=function()
 clearOptions()
 local c=popupOwner;if not c then return end
 local q=string.lower(popupSearch.Text);local n=0
 local function option(text,value)
  local b=button(popupList,"Option"..n,0,n*43,551,37,8);b.ZIndex=32
  b.BackgroundTransparency=0;b.BackgroundColor3=rgb(value==c.value and "#713175" or P.panel)
  label(b,"Label",text,12,0,526,37,15,P.white,false,33)
  popupConnections[#popupConnections+1]=b.Activated:Connect(function()
   if c.busy then return end
   c.value=value;c.valueLabel.Text=value or "请选择";closePopup();invoke(c,value)
  end)
  n=n+1
 end
 if c.options.AllowNone then option("清除选择",nil) end
 for _,value in ipairs(c.values) do
  if string.find(string.lower(tostring(value)),q,1,true) then option(tostring(value),value) end
 end
 if n==0 then label(popupList,"EmptyOptions","没有可选项，请稍后刷新",12,0,520,44,16,P.pearl,false,33);n=1 end
 popupList.CanvasSize=UDim2.fromOffset(0,n*43)
end
connect(popupClose.Activated,closePopup)
connect(popupSearch:GetPropertyChangedSignal("Text"),drawOptions)
connect(shell:GetPropertyChangedSignal("Visible"),function() if not shell.Visible then closePopup() end end)
local activeSlider,sliderInput=nil,nil
local function sliderAt(c,x)
 local low,high=c.options.Value.Min,c.options.Value.Max
 local a=math.clamp((x-c.slider.AbsolutePosition.X)/math.max(1,c.slider.AbsoluteSize.X),0,1)
 local step=10^(c.options.Value.Precision or 0)
 local value=math.clamp(math.floor((low+(high-low)*a)*step+.5)/step,low,high)
 if value==c.value then return end
 c.value=value;c.valueLabel.Text=tostring(value)
 c.fill.Size=UDim2.fromScale((value-low)/math.max(1,high-low),1)
 c.thumb.Position=UDim2.fromScale((value-low)/math.max(1,high-low),.5)
 invoke(c,value)
end
connect(UserInputService.InputChanged,function(input)
 if activeSlider and (input==sliderInput or (sliderInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement)) then sliderAt(activeSlider,input.Position.X) end
end)
connect(UserInputService.InputEnded,function(input)
 if activeSlider and (input==sliderInput or input.UserInputType==Enum.UserInputType.MouseButton1) then activeSlider=nil;sliderInput=nil end
end)
connect(UserInputService.WindowFocusReleased,function() activeSlider=nil;sliderInput=nil end)
local function addControl(tab,kind,options)
 options=options or {}
 local originalTitle=options.Title or ""
 local title=displayNames[originalTitle] or originalTitle
 local height=(kind=="Section" and 30) or (kind=="Divider" and 4) or ((kind=="Input" or kind=="Dropdown" or kind=="Slider") and 92) or 64
 local b=button(scroll,kind.."_"..(#cards+1),4,4,566,height,11)
 local fill=gradient(b,{{0,"#4B1B50"},{.6,"#2A103F"},{1,"#5A2572"}},15)
 b.BackgroundTransparency=.01;b.BackgroundColor3=WHITE
 local edge=stroke(b,P.pearl,1,.6)
 local c={button=b,item={id=tostring(#cards+1),label=title,category=tab.id},originalTitle=originalTitle,kind=kind,options=options,edge=edge,fill=fill,y=4,height=height,hover=false,sweep=2,busy=false}
 cards[#cards+1]=c;b:SetAttribute("ControlType",kind);b:SetAttribute("OriginalTitle",originalTitle)
 local handle={};c.handle=handle
 if kind=="Divider" then
  b.BackgroundTransparency=1;edge.Transparency=1
  frame(b,"Rule",12,1,540,1,P.pearl,nil,6,.75)
 elseif kind=="Section" then
  b.BackgroundTransparency=1;edge.Transparency=1
  label(b,"SectionTitle",title,12,0,530,30,13,P.pearl,true)
 else
  local name=label(b,"FeatureName",title,16,0,kind=="Toggle" and 350 or 530,kind=="Toggle" and height or 40,16,P.white,true)
  name.TextTruncate=Enum.TextTruncate.AtEnd
  if kind=="Toggle" then
   c.value=options.Value==true
   c.state=label(b,"State","已关闭",382,0,82,height,12,P.pearl)
   c.track=frame(b,"Switch",482,19,50,26,"#5A3565",13,6)
   c.knob=frame(c.track,"Knob",3,3,20,20,P.white,10,7)
   syncToggle(c)
   connect(b.Activated,function()
    if not popup.Visible and not c.busy then c.value=not c.value;invoke(c,c.value) end
   end)
  elseif kind=="Button" then
   name.Size=UDim2.fromOffset(415,height)
   c.state=label(b,"State","执行 ›",452,0,102,height,13,P.pearl)
   connect(b.Activated,function()
    if popup.Visible then return end
    gui:SetAttribute("SelectedFeature",title);actionEvent:Fire(title);invoke(c)
   end)
  elseif kind=="Input" then
   local box=make("TextBox",{Name="Value",Position=UDim2.fromOffset(16,43),Size=UDim2.fromOffset(532,37),BackgroundColor3=rgb(P.base),BorderSizePixel=0,Text=tostring(options.Value or ""),PlaceholderText=options.Placeholder or "请输入",ClearTextOnFocus=options.ClearTextOnFocus==true,TextColor3=rgb(P.white),PlaceholderColor3=rgb(P.pearl),TextSize=21,Font=Enum.Font.Gotham,ZIndex=7},b)
   corner(box,7)
   connect(box.FocusLost,function() invoke(c,box.Text) end)
  elseif kind=="Dropdown" then
   c.values=table.clone(options.Values or {});c.value=options.Value
   c.valueLabel=label(b,"Value",c.value or "请选择",16,41,494,40,15,P.pearl)
   c.valueLabel.TextTruncate=Enum.TextTruncate.AtEnd
   label(b,"Arrow","⌄",520,41,26,40,20,P.pearl)
   function handle:Refresh(values,clear)
    c.values=table.clone(values or {})
    if clear or (c.value~=nil and not table.find(c.values,c.value)) then
     c.value=nil;c.valueLabel.Text="请选择";invoke(c,nil)
    end
    if popupOwner==c then drawOptions() end
   end
   connect(b.Activated,function() if not c.busy then openPopup(c) end end)
  elseif kind=="Slider" then
   local v=options.Value;c.value=v.Default
   name.Size=UDim2.fromOffset(440,40)
   c.valueLabel=label(b,"Value",tostring(c.value),480,0,70,40,16,P.pearl,true)
   c.slider=button(b,"Slider",20,45,526,34,0);c.slider.ZIndex=7
   local track=frame(c.slider,"Track",0,14,526,6,"#5A3565",3,7)
   c.fill=frame(track,"Fill",0,0,0,6,P.pink,3,8)
   local a=(c.value-v.Min)/math.max(1,v.Max-v.Min)
   c.fill.Size=UDim2.fromScale(a,1)
   c.thumb=frame(track,"Thumb",0,0,18,18,P.white,9,9);c.thumb.AnchorPoint=Vector2.new(.5,.5);c.thumb.Position=UDim2.fromScale(a,.5)
   connect(c.slider.InputBegan,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
     activeSlider=c;sliderInput=input;sliderAt(c,input.Position.X)
    end
   end)
  end
  connect(b.MouseEnter,function() tween(edge,{Transparency=.15},.16) end)
  connect(b.MouseLeave,function() tween(edge,{Transparency=(kind=="Toggle" and c.value) and .12 or .6},.16) end)
 end
 filterCards(false)
 return handle
end
local tabCount=0
function adapter:CreateWindow(options)
 shell.Title.Text="JBS 力量传奇"
 shell.Tribe.Text=""
 shell.Tribe.Visible=false
 return window
end
function window:Tab(options)
 tabCount=tabCount+1;local nav=scene.navigation[tabCount]
 assert(nav,"界面页面数量超出配置")
 local tab={id=nav.id}
 for _,kind in ipairs({"Input","Toggle","Button","Dropdown","Slider","Section","Divider"}) do
  tab[kind]=function(self,opts) return addControl(self,kind,opts) end
 end
 return tab
end
for i,m in ipairs(menuButtons) do
 connect(m.button.Activated,function()
  closePopup();activeSlider=nil;sliderInput=nil
  category=m.item.id;gui:SetAttribute("SelectedPage",category);pageTitle.Text=m.item.label
  tween(selection,{Position=UDim2.fromOffset(8,90+(i-1)*72)},.28)
  for _,other in ipairs(menuButtons) do other.title.TextColor3=rgb(other==m and P.white or P.pearl) end
  filterCards(true)
 end)
end
connect(search:GetPropertyChangedSignal("Text"),function() filterCards(true) end)
connect(gui.Destroying,clearOptions)

local elapsed,acc=0,0
local visible=true
local animation
local function render(t,dt)
 local pointer=UserInputService:GetMouseLocation()
 local mx=math.clamp((pointer.X-content.AbsolutePosition.X)/math.max(1,content.AbsoluteSize.X),0,1)
 local angle=28+(mx-.5)*20
 contentMetal.Rotation=angle+math.sin(t*.3)*8
 contentMetal.Offset=Vector2.new(math.sin(t*.22)*.12,0)
 shellMetal.Rotation=30+math.sin(t*.25)*10
 rimGradient.Rotation=(t*40)%360
 rimGradient.Offset=Vector2.new(math.sin(t*.7)*.35,math.cos(t*.7)*.35)
 logoGradient.Offset=Vector2.new(math.sin(t*.8)*.65,0)
 sideLogoGradient.Offset=Vector2.new(math.sin(t*.5)*.45,0)
 for _,g in ipairs(glyphs) do
  local beam=(t/7.2%1)*(g.width+619*.52+330)-180
  local d=(g.x+g.y*(.48+(mx-.5)*.12))-beam
  local light=math.exp(-((d/63)^2))
  local narrow=math.exp(-((d/16)^2))
  g.object.TextTransparency=1-math.min(1,g.base+light*.3+narrow*.32)
  g.object.TextColor3= d<0 and rgb(P.pink):Lerp(WHITE,1-light*.35) or rgb(P.pearl):Lerp(WHITE,1-light*.4)
 end
 for _,s in ipairs(stars) do s.object.BackgroundTransparency=.35+.6*(.5+.5*math.sin(t*(.8+s.phase*.03)+s.phase)) end
 for _,c in ipairs(cards) do
  if c.sweep<1.2 and c.hover and c.button.Visible then c.sweep=c.sweep+dt*3;c.shine.Offset=Vector2.new(c.sweep,0) end
 end
 for _,c in ipairs(cards) do syncToggle(c) end
end
local function stop()
 if animation then animation:Disconnect();animation=nil end
 for t in pairs(tweens) do t:Cancel() end
 table.clear(tweens)
 for object in pairs(temporaries) do object:Destroy() end
 table.clear(temporaries)
 shell.Position=UDim2.fromOffset(0,0)
 list.Position=UDim2.fromOffset(22,116)
 for i,m in ipairs(menuButtons) do if m.item.id==category then selection.Position=UDim2.fromOffset(8,90+(i-1)*72) end end
 for _,c in ipairs(cards) do c.button.Position=UDim2.fromOffset(4,c.y) end
end
local function start()
 if animation or destroyed or not visible or not gui.Enabled then return end
 animation=RunService.RenderStepped:Connect(function(dt)
  acc=acc+dt
  if acc<1/30 then return end
  local step=acc;acc=0;elapsed=elapsed+step;render(elapsed,step)
 end)
end
local function reveal()
 visible=true;shell.Visible=true;restore.Visible=false;elapsed=0;acc=0
 for _,g in ipairs(glows) do g.object.Visible=true end
 shell.Position=UDim2.fromOffset(0,20)
 tween(shell,{Position=UDim2.fromOffset(0,0)},.7)
 list.Position=UDim2.fromOffset(22,128);tween(list,{Position=UDim2.fromOffset(22,116),},.5,.3)
 start()
end
local function hide()
 closePopup();activeSlider=nil;sliderInput=nil
 visible=false;stop();shell.Visible=false;restore.Visible=true;notice.Visible=false
 for _,g in ipairs(glows) do g.object.Visible=false end
end
connect(close.Activated,hide);connect(minimize.Activated,hide)
connect(restore.Activated,function() if restoreMoved then restoreMoved=false return end reveal() end)
connect(expand.Activated,function() expanded=not expanded;fit() end)
connect(gui:GetPropertyChangedSignal("Enabled"),function() if gui.Enabled then start() else stop() end end)
connect(UserInputService.WindowFocusReleased,stop)
connect(UserInputService.WindowFocused,start)
connect(shell:GetPropertyChangedSignal("Visible"),function() if shell.Visible and visible then start() else stop() end end)
connect(gui.Destroying,function()
 destroyed=true;stop()
 for _,c in ipairs(connections) do c:Disconnect() end
end)
local showEvent=make("BindableEvent",{Name="ShowWindow"},gui)
connect(showEvent.Event,reveal)
gui:SetAttribute("SelectedPage","main")
filterCards(false);render(0,0);reveal()

function adapter:Show() if not destroyed then reveal() end end
function adapter:Destroy() if not destroyed then gui:Destroy() end end
function adapter:IsAlive() return not destroyed and gui.Parent~=nil end
return adapter
end

function Library:CreateWindow(options)
 if instance and instance:IsAlive() then instance:Show();return window end
 if self.GameState=="running" or self.GameState=="failed" then error("JBS 界面已失效，请重新进入游戏，避免重复功能循环",0) end
 checkLegacy()
 local before=currentGui():FindFirstChild("JBS_Metal_v31")
 local ok,result=pcall(createRenderer)
 if not ok then
  local gui=currentGui():FindFirstChild("JBS_Metal_v31")
  if gui and gui~=before and gui:GetAttribute("JBSLibraryVersion")=="3.2" then gui:Destroy() end
  error(result,0)
 end
 instance=result
 window=instance:CreateWindow(options or {})
 for _,message in ipairs(self.PendingNotifications or {}) do instance:Notify(message) end
 self.PendingNotifications=nil
 return window
end
function Library:Notify(options)
 if instance and instance:IsAlive() then return instance:Notify(options) end
 self.PendingNotifications=self.PendingNotifications or {}
 self.PendingNotifications[#self.PendingNotifications+1]=options
end
function Library:Show()
 if instance and instance:IsAlive() then instance:Show() end
end
function Library:Destroy()
 assert(self.GameState=="idle","游戏功能仍属于当前会话，请重新进入游戏后换版；不能只销毁 UI 再重复初始化功能")
 if instance then instance:Destroy() end
 instance=nil;window=nil
end
function Library:BeginGame()
 if self.GameState=="running" then
  assert(instance and instance:IsAlive(),"JBS 界面已失效，请重新进入游戏，避免重复功能循环")
  self:Show();return false,"already-running"
 end
 if self.GameState=="starting" or self.GameState=="checking" then return false,"already-starting" end
 assert(self.GameState~="failed","JBS 上次启动未完成，请重新进入游戏后重试")
 self.GameState="checking"
 local ok,err=pcall(function()
  local conflict=legacyConflict()
  if not conflict then
   for _,key in ipairs({"auto_train","auto_rebirth","auto_wheel","auto_petbuy","auto_packrebirth","auto_eategg","auto_fasttrain","auto_boss"}) do
    if rawget(_G,key)~=nil then conflict="旧版 JBS 功能状态";break end
   end
  end
  assert(not conflict,"检测到旧 JBS（"..tostring(conflict).."）。请重新进入游戏，仅运行新版启动文件。")
 end)
 if not ok then self.GameState="idle";error(err,0) end
 self.GameState="starting"
 return true
end
function Library:FinishGame(ok,err)
 self.GameState=ok and "running" or "failed"
 self.LastError=ok and nil or tostring(err)
end
environment[KEY]=Library
return Library
end

return loadLibrary()