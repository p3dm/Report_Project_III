= Triển khai phần mềm

== Triển khai khởi tạo CameraX cho camera.

=== Yêu cầu quyền tại AndroidManifest.xml

Tại *AndroidManifest.xml*, các hàm kiểm tra và yêu cầu quyền sử dụng camera, ghi âm, internet cũng như quyền ghi dữ liệu ra bộ nhớ ngoài được xây dựng.

```xml
<uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name ="android.permission.CAMERA" />
    <uses-permission android:name ="android.permission.RECORD_AUDIO" />
    <uses-permission android:name = "android.permission.WRITE_EXTERNAL_STORAGE"android:maxSdkVersion="28" />
    <uses-feature android:name="android.hardware.camera.any" />
```.

"android.permission.INTERNET": Quyền truy cập Internet, cho phép ứng dụng kết nối mạng để gửi dữ liệu video/âm thanh lên server hoặc tải dữ liệu từ API.

"android.permission.CAMERA": Quyền sử dụng camera, cho phép ứng dụng truy cập camera của thiết bị để quay video hoặc chụp ảnh.

"android.permission.RECORD_AUDIO": Quyền ghi âm, cho phép ứng dụng thu âm thanh từ microphone trong quá trình quay video.

"android.permission.WRITE_EXTERNAL_STORAGE": Quyền ghi dữ liệu ra bộ nhớ ngoài, cho phép ứng dụng lưu các file video/ảnh đã quay vào thư mục của thiết bị.

"android.hardware.camera.any": Đảm bảo thiết bị có camera (bắt buộc)

=== Lớp PermissionHelper - Quản lý quyền ứng dụng

==== Mục đích và thiết kế

Lớp `PermissionHelper` được thiết kế để quản lý việc yêu cầu và kiểm tra quyền của ứng dụng theo cách tiêu chuẩn của Android. Lớp này sử dụng `ActivityResultLauncher` để xử lý kết quả yêu cầu quyền một cách hiệu quả.

==== Cấu trúc thành phần

Lớp `PermissionHelper` nhận hai tham số trong constructor:

- `activity: MainActivity`: Tham chiếu đến  activity chính của ứng dụng, dùng để kiểm tra trạng thái quyền

- `launcher: ActivityResultLauncher<Array<String>>`: Công cụ khởi chạy yêu cầu quyền, được khởi tạo từ activity bằng `registerForActivityResult()`

=== Các phương thức chính

*a. requestPermissions()*

Phương thức này yêu cầu tất cả các quyền cần thiết của ứng dụng:

```kotlin
fun requestPermissions() {
    launcher.launch(MainActivity.REQUIRED_PERMISSIONS)
}
```
*b. allPermissionsGranted(): Boolean*

Phương thức này kiểm tra xem tất cả các quyền cần thiết đã được cấp hay chưa:

```kotlin
fun allPermissionsGranted(): Boolean = MainActivity.REQUIRED_PERMISSIONS.all{
    ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED
}
```
Hoạt động:
- Duyệt qua từng quyền trong danh sách `REQUIRED_PERMISSIONS`
- Sử dụng `ContextCompat.checkSelfPermission()` để kiểm tra trạng thái của mỗi quyền
- Trả về `true` chỉ khi tất cả quyền đều được cấp (`PackageManager.PERMISSION_GRANTED`)
- Trả về `false` nếu có bất kỳ quyền nào chưa được cấp

*c.handlePermissionResult(permissions: Map< String, Boolean >): Boolean*

Phương thức này xử lý kết quả sau khi người dùng quyết định về các quyền yêu cầu:
\
\
\
\
\
\
```kotlin
fun handlePermissionResult(permissions: Map<String, Boolean>): Boolean {
    var permissionGranted = true
    permissions.entries.forEach {
        if (it.key in MainActivity.REQUIRED_PERMISSIONS && !it.value) {
            permissionGranted = false
        }
    }
    return permissionGranted
}
```
\
Hoạt động:
- Nhận một Map chứa quyền và trạng thái của chúng (true = được cấp, false = bị từ chối)
- Kiểm tra xem quyền nào là bắt buộc (`it.key in MainActivity.REQUIRED_PERMISSIONS`)
- Nếu bất kỳ quyền bắt buộc nào bị từ chối (`!it.value`), đặt `permissionGranted = false`
- Trả về `true` chỉ khi tất cả quyền bắt buộc đều được cấp, ngược lại trả về `false`

=== Lớp CameraController - Điều khiển Camera và Quay Video

==== Mục đích và thiết kế

Lớp `CameraController` được thiết kế để quản lý toàn bộ các chức năng liên quan đến camera, bao gồm chụp ảnh, quay video, chuyển đổi giữa các chế độ, và điều khiển camera trước/sau. Lớp này sử dụng CameraX library của Android để cung cấp giao diện hiện đại và linh hoạt.

==== Cấu trúc thành phần

Lớp `CameraController` nhận ba tham số trong constructor:

- `activity: MainActivity`: Tham chiếu đến activity chính, dùng để quản lý lifecycle và UI
- `viewBinding: ActivityMainBinding`: Binding view để truy cập các UI component
- `cameraExecutor: ExecutorService`: Executor service để thực thi các tác vụ nặng trên background thread

==== Các phương thức chính

*a. startCamera()*
```kotlin
fun startCamera() {
    val cameraProviderFuture = ProcessCameraProvider.getInstance(activity)
    cameraProviderFuture.addListener({
            val cameraProvider: ProcessCameraProvider = cameraProviderFuture.get()
            
            // Tạo Preview use case
            val preview = Preview.Builder()
                .build()
                .also {
                    it.surfaceProvider = viewBinding.viewFinder.surfaceProvider
                }
            
            // Tạo Recorder với Quality cao nhất
            val recorder = Recorder.Builder()
                .setQualitySelector(QualitySelector.from(Quality.HIGHEST))
                .build()
            videoCapture = VideoCapture.withOutput(recorder)
            
            // Tạo ImageCapture use case
            imageCapture = ImageCapture.Builder().build()
            
            // Chọn camera (trước hoặc sau)
            val cameraSelector = if (currentSite == CameraSite.BACK) {
                CameraSelector.DEFAULT_BACK_CAMERA
            } else {
                CameraSelector.DEFAULT_FRONT_CAMERA
            }
            
            // Unbind tất cả use cases cũ
            cameraProvider.unbindAll()
            
            // Bind các use cases mới
            cameraProvider.bindToLifecycle(
                activity,
                cameraSelector,
                preview,
                imageCapture,
                videoCapture
            )
}
```
Hoạt động:
- Lấy ProcessCameraProvider instance để quản lý lifecycle camera
- Tạo Preview use case để hiển thị xem trước trên PreviewView
- Tạo Recorder với Quality.HIGHEST cho chất lượng video tốt nhất
- Tạo ImageCapture use case cho chụp ảnh
- Chọn camera phù hợp (trước hoặc sau)
- Unbind tất cả use cases cũ trước khi bind mới
- Ràng buộc tất cả use cases với lifecycle của activity

*b. takePhoto()*

Phương thức này chụp ảnh và lưu vào MediaStore của thiết bị.

Hoạt động:
- Tạo tên file theo định dạng thời gian: `dd-MM-yyyy-HH-mm-ss-SSS`
- Thiết lập ContentValues với MIME type "image/jpeg"
- Lưu ảnh vào thư mục "CameraX" trên thiết bị (từ Android 10+)
- Tạo OutputFileOptions với MediaStore URI
- Ghi ảnh nhị phân và trả về callback
- Cập nhật thumbnail trên UI thread
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
```kotlin
fun takePhoto() {
    val imageCapture = imageCapture ?: return

    val name = SimpleDateFormat(FILENAME_FORMAT, Locale.US)
        .format(System.currentTimeMillis())
    val contentValues = ContentValues().apply {
        put(MediaStore.MediaColumns.DISPLAY_NAME, name)
        put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
        if(Build.VERSION.SDK_INT > Build.VERSION_CODES.P) {
            put(MediaStore.Images.Media.RELATIVE_PATH, "CameraX")
        }
    }
    val outputOptions = ImageCapture.OutputFileOptions
        .Builder(activity.contentResolver,
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            contentValues)
        .build()
    
    imageCapture.takePicture(
        outputOptions,
        ContextCompat.getMainExecutor(activity),
        object : ImageCapture.OnImageSavedCallback {
            override fun onError(exc: ImageCaptureException) {
                Log.e(TAG, "Photo capture failed: ${exc.message}", exc)
            }
            override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                val savedUri = output.savedUri
                if (savedUri != null) {
                    // Cập nhật thumbnail lên nút thư viện
                    activity.runOnUiThread {
                        viewBinding.photoViewButton.setImageURI(savedUri)
                        viewBinding.photoViewButton.clipToOutline = true
                    }
                }
                val msg = "Photo capture succeeded: ${output.savedUri}"
                Log.d(TAG, msg)
            }
        }
    )
}
```
\
\
\
*c.captureVideo()*

Phương thức này bắt đầu hoặc dừng quay video với support cho âm thanh.

```kotlin
fun captureVideo() {
    val videoCapture = this.videoCapture ?: return
    
    viewBinding.modeSelectorGroup.isEnabled = false
    
    val curRecording = recording
    if (curRecording != null) {
        // Nếu đang quay, dừng lại
        curRecording.stop()
        recording = null
        return
    }
    
    // Bắt đầu quay video
    val name = SimpleDateFormat(FILENAME_FORMAT, Locale.US)
        .format(System.currentTimeMillis())
    val contentValues = ContentValues().apply {
        put(MediaStore.MediaColumns.DISPLAY_NAME, name)
        put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4")
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.P) {
            put(MediaStore.Video.Media.RELATIVE_PATH, "CameraX")
        }
    }
    
    val mediaStoreOutputOptions = MediaStoreOutputOptions
        .Builder(activity.contentResolver, MediaStore.Video.Media.EXTERNAL_CONTENT_URI)
        .setContentValues(contentValues)
        .build()
    
    recording = videoCapture.output
        .prepareRecording(activity, mediaStoreOutputOptions)
        .apply {
            // Thêm âm thanh nếu có quyền
            if (PermissionChecker.checkSelfPermission(activity,
                    Manifest.permission.RECORD_AUDIO) ==
                PermissionChecker.PERMISSION_GRANTED) {
                withAudioEnabled()
            }
        }
        .start(ContextCompat.getMainExecutor(activity)) { recordEvent ->
            when(recordEvent) {
                is VideoRecordEvent.Start -> {
                    recordingTimer.start()
                    viewBinding.recordingIndicator.visibility = View.VISIBLE
                    updateCaptureButtonUI()
                    viewBinding.modeSelectorGroup.isEnabled = false
                }
                
                is VideoRecordEvent.Finalize -> {
                    if (!recordEvent.hasError()) {
                        recordingTimer.stop()
                        viewBinding.recordingIndicator.visibility = View.GONE
                        recording = null
                        
                        // Lấy frame đầu tiên làm thumbnail
                        val savedUri = recordEvent.outputResults.outputUri
                        if(savedUri != null){
                            cameraExecutor.execute {
                                val retriever = MediaMetadataRetriever()
                                try{
                                    retriever.setDataSource(activity, savedUri)
                                    val savedVideo = retriever.getFrameAtTime(0, 
                                        MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                                    activity.runOnUiThread {
                                        viewBinding.photoViewButton.setImageBitmap(savedVideo)
                                        viewBinding.photoViewButton.clipToOutline = true
                                    }
                                }catch(e: Exception){
                                    Log.e(TAG, "Lỗi xuất video: ${e.message}")
                                }finally {
                                    retriever.release()
                                }
                            }
                        }
                        Log.d(TAG, "Video capture succeeded: ${recordEvent.outputResults.outputUri}")
                    } else {
                        recording?.close()
                        recording = null
                        Log.e(TAG, "Video capture ends with error: ${recordEvent.error}")
                    }
                    updateCaptureButtonUI()
                    viewBinding.modeSelectorGroup.isEnabled = true
                }
            }
        }
}
```

Hoạt động:
- Kiểm tra nếu đang quay video, dừng lại và trả về
- Nếu không, bắt đầu ghi video với MediaStoreOutputOptions
- Kích hoạt RECORD_AUDIO nếu có quyền
- Xử lý VideoRecordEvent.Start: khởi động timer, hiển thị indicator
- Xử lý VideoRecordEvent.Finalize: dừng timer, lấy frame đầu làm thumbnail
- Sử dụng MediaMetadataRetriever để trích xuất thumbnail từ video

*d. flipCamera()*

Phương thức này chuyển đổi giữa camera trước và sau.

```kotlin
fun flipCamera(){
    viewBinding.flipCameraButton.animate()
        .rotation(180f)
        .setDuration(300)
        .start()
    
    if(currentSite == CameraSite.BACK){
        currentSite = CameraSite.FRONT
        lensFacing = CameraSelector.LENS_FACING_FRONT
    } else {
        currentSite = CameraSite.BACK
        lensFacing = CameraSelector.LENS_FACING_BACK
    }
    
    startCamera()
}
```

Hoạt động:
- Tạo hiệu ứng xoay 180° cho nút flip camera trong 300ms
- Chuyển đổi currentSite giữa FRONT và BACK
- Cập nhật lensFacing tương ứng
- Gọi startCamera() để khởi động lại camera với vị trí mới

*e. updateCaptureButtonUI()*

Phương thức này cập nhật giao diện nút capture dựa trên chế độ hiện tại.

```kotlin
fun updateCaptureButtonUI() {
    activity.runOnUiThread {
        currentMode = if(viewBinding.modeSelectorGroup.checkedRadioButtonId 
            == R.id.photo_mode_button) {
            CaptureMode.PHOTO
        } else {
            CaptureMode.VIDEO
        }
        
        viewBinding.captureButton.apply {
            when (currentMode) {
                CaptureMode.PHOTO -> {
                    setImageResource(0)
                    setBackgroundResource(R.drawable.capture_button)
                    contentDescription = context.getString(R.string.take_photo)
                }
                
                CaptureMode.VIDEO -> {
                    val isRecording = recording != null
                    val backgroundRes = if (isRecording) 
                        R.drawable.recording_button else R.drawable.video_button
                    val descriptionRes = if (isRecording) 
                        R.string.stop_capture else R.string.start_capture
                    
                    setBackgroundResource(backgroundRes)
                    contentDescription = context.getString(descriptionRes)
                }
            }
        }
    }
}
```

Hoạt động:
- Chạy trên UI thread bằng runOnUiThread
- Cập nhật currentMode dựa trên radio button được chọn
- Nếu PHOTO: sử dụng capture_button drawable
- Nếu VIDEO: sử dụng recording_button hoặc video_button tùy theo trạng thái

=== Lớp CameraSocketServer - Server điều khiển Camera Từ Xa

==== Mục đích và thiết kế

Lớp `CameraSocketServer` được thiết kế để tạo một socket server lắng nghe các kết nối từ client từ xa. Server này nhận các lệnh điều khiển camera qua network và xử lý chúng thông qua callback handler.

==== Cấu trúc thành phần

Lớp `CameraSocketServer` nhận hai tham số trong constructor:

- `executor: ExecutorService`: Executor service để chạy server trên background thread
- `commandHandler: (String) -> Unit`: Callback lambda để xử lý các lệnh nhận được từ client

==== Các phương thức chính

*a. start() - Khởi động Socket Server*

Khởi động socket server lắng nghe trên port 2000 và chấp nhận kết nối từ client.

```kt
fun start(){
        executor.execute {
              serverSocket = ServerSocket(SEVER_PORT)
              isRunning = true
              Log.d(TAG, "Server started on port $SEVER_PORT")
              while (isRunning && !Thread.currentThread().isInterrupted) {
                val clientSocket = serverSocket?.accept()
                  if(hasClient.get()){
                    val writer = PrintWriter(
                              BufferedWriter(
                                  OutputStreamWriter(clientSocket?.outputStream)),true)
                          writer.println("SERVER_BUSY")
                      } else {
                          Log.d(TAG, "Client connected: ${clientSocket?.inetAddress}")
                          currentClientSocket = clientSocket
                          hasClient.set(true)
                          handleClient(clientSocket!!)
                      }
          } 
}
```
Hoạt động:
- Tạo ServerSocket lắng nghe trên port 2000
- Đặt flag `isRunning = true` để chỉ định server đang chạy
- Vòng lặp liên tục chấp nhận kết nối từ client
- Kiểm tra nếu đã có client kết nối, từ chối client mới với "SERVER_BUSY"
- Nếu không có client, lưu socket và gọi `handleClient()`

*b. handleClient() - Xử lý Lệnh từ Client*

Xử lý các lệnh từ client đã kết nối và gửi phản hồi.
```kt
fun handleClient(clientSocket: Socket){
        try {
            clientSocket.use { socket ->
                val reader = BufferedReader(InputStreamReader(socket.inputStream))

                val writer = PrintWriter(
                    BufferedWriter(OutputStreamWriter(socket.outputStream)),
                    true
                )
                writer.println("CONNECTED_TO_SERVER")
                while (isRunning && !clientSocket.isClosed && hasClient.get()) {
                    val command = reader.readLine()
                    if (command == null) {
                        // Client đã ngắt kết nối
                        Log.d(TAG, "Client disconnected: ${clientSocket.inetAddress}")
                        break
                    }else{
                        commandHandler(command)
                        writer.println("COMMAND_RECEIVED: $command")
                    }
                }
            }
        }catch(e: Exception){
            Log.e(TAG, "Error: Handling client", e)
        }
    }
```
Hoạt động:
- Sử dụng `use {}` để tự động đóng socket khi hoàn tất
- Tạo BufferedReader để đọc lệnh từ client
- Tạo PrintWriter để gửi phản hồi về client
- Gửi "CONNECTED_TO_SERVER" để xác nhận kết nối
- Vòng lặp đọc các lệnh từ client line-by-line
- Nếu nhận được lệnh, gọi `commandHandler(command)` để xử lý
- Gửi lại xác nhận "COMMAND_RECEIVED" đến client

*c.getLocalIpAddress() - Lấy Địa chỉ IP Local*

Lấy địa chỉ IP local (IPv4) của thiết bị để chia sẻ với client.
```kt
fun getLocalIpAddress(): String {
        try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            while (interfaces.hasMoreElements()) {
                val networkInterface = interfaces.nextElement()
                val addresses = networkInterface.inetAddresses
                while (addresses.hasMoreElements()) {
                    val address = addresses.nextElement()
                    if (!address.isLoopbackAddress && address is Inet4Address) {
                        return address.hostAddress ?: "Unknown"
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return "Unable to get IP"
    }
```
Hoạt động:
- Duyệt qua tất cả các network interfaces của thiết bị
- Lấy tất cả các địa chỉ từ mỗi interface
- Lọc ra các địa chỉ IPv4 thực sự (không phải loopback)
- Trả về địa chỉ IP đầu tiên tìm được
- Nếu không tìm được, trả về "Unable to get IP"

*d. stop() - Dừng Socket Server*

Dừng server và đóng tất cả các kết nối.

Hoạt động:
- Đặt `isRunning = false` để dừng vòng lặp chính
- Gửi "SERVER_SHUTDOWN" để thông báo client
- Đóng ServerSocket
- Reset tất cả các biến trạng thái
```kt
fun stop(){
        isRunning = false
        currentClientSocket?.let{socket ->
            if(!socket.isClosed){
                try{
                    val writer = PrintWriter(
                        BufferedWriter(OutputStreamWriter(socket.outputStream)),
                        true
                    )
                    writer.println("SERVER_SHUTDOWN")
                    Thread.sleep(100)
                    serverSocket?.close()
                    serverSocket = null

                }catch(e: Exception){
                    e.printStackTrace()
                }

            }
        }
        currentClientSocket = null
        hasClient.set(false)
        serverSocket?.close()
        serverSocket = null

    }
```

=== Lớp RemoteCommandHandler - Xử Lý Lệnh Điều Khiển Từ Xa

==== Mục đích và thiết kế

Lớp `RemoteCommandHandler` được thiết kế để xử lý các lệnh điều khiển camera từ client thông qua socket server. Lớp này chuyển đổi các lệnh text sang các hành động camera (chụp ảnh, quay video).

==== Cấu trúc thành phần

Lớp `RemoteCommandHandler` nhận hai tham số trong constructor:

- `viewBinding: ActivityMainBinding`: Binding view để truy cập UI components
- `cameraController: CameraController`: Controller để gọi các phương thức camera

==== Các phương thức chính

*a. handleRemoteCommand() - Xử lý Lệnh Từ Xa*

```kotlin
fun handleRemoteCommand(command: String) {
    when (command.uppercase()) {
        "TAKE_PHOTO" -> {
            cameraController.switchToPhotoMode()
            Log.d(TAG, "Executing takePhoto() via remote command.")
            viewBinding.captureButton.performClick()
        }
        
        "RECORD" -> {
            Log.d(TAG, "Executing captureVideo() via remote command.")
            cameraController.switchToVideoMode()
            viewBinding.captureButton.performClick()
        }
        
        else -> {
            Log.w(TAG, "Unknown command received: $command")
        }
    }
}
```

Hoạt động:
- Chuyển đổi lệnh sang chữ hoa (không phân biệt hoa/thường)
- Nếu lệnh là "TAKE_PHOTO":
  - Gọi `switchToPhotoMode()` để chuyển sang chế độ chụp ảnh
  - Gọi `performClick()` trên nút capture để chụp ảnh
- Nếu lệnh là "RECORD":
  - Gọi `switchToVideoMode()` để chuyển sang chế độ quay video
  - Gọi `performClick()` trên nút capture để bắt đầu quay
- Nếu lệnh không nhận diện, in log warning

==== Quy trình hoạt động tổng thể

1. Client từ xa kết nối đến CameraSocketServer trên port 2000
2. Server chấp nhận kết nối và gửi "CONNECTED_TO_SERVER"
3. Client gửi lệnh (ví dụ: "TAKE_PHOTO")
4. Server nhận lệnh và gọi `commandHandler(command)`
5. RemoteCommandHandler xử lý lệnh:
   - Kiểm tra loại lệnh
   - Chuyển đổi chế độ camera nếu cần
   - Gọi `performClick()` trên nút capture
6. CameraController thực thi hành động (chụp ảnh hoặc quay video)
7. Server gửi "COMMAND_RECEIVED: [lệnh]" về client
8. Client có thể gửi thêm lệnh hoặc ngắt kết nối

==== Lợi ích của thiết kế này

- *Điều khiển từ xa*: Cho phép điều khiển camera từ một thiết bị khác qua network
- *Asynchronous*: Sử dụng ExecutorService để không chặn UI thread
- *Flexible*: Dễ dàng mở rộng thêm các lệnh mới (FLIP_CAMERA, ZOOM, v.v.)
- *Stable*: Xử lý các exception và ngắt kết nối một cách graceful
- *Single Client*: Chỉ cho phép một client kết nối cùng một lúc, tránh xung đột

=== Lớp CameraSocketClient - Client Socket để Kết nối Server

==== Mục đích và thiết kế

Lớp `CameraSocketClient` được thiết kế để tạo một client socket kết nối đến CameraSocketServer. Client này cho phép gửi các lệnh điều khiển camera từ xa và lắng nghe các phản hồi từ server.

==== Cấu trúc thành phần

Lớp `CameraSocketClient` nhận ba tham số trong constructor:

- `serverHost: String`: Địa chỉ IP hoặc hostname của server
- `serverPort: Int`: Cổng server (mặc định 2000)
- `listener: CameraClientListener`: Interface callback để nhận các sự kiện từ server

==== Các phương thức chính

*a. connect() - Kết nối đến Server*

Phương thức này tạo kết nối socket đến server.
\
\
\
\
\
\
\
\
\
\
\
\
```kotlin
fun connect(){
    if(isConnected.get()){
        Log.d(TAG, "Client already connected")
        return
    }
    executor.execute {
        try{
            val clientSocket = Socket().apply {
                keepAlive = true           // Giữ kết nối sống
                tcpNoDelay = true          // Tắt Nagle's algorithm
                soTimeout = 0              // Timeout vô hạn
                connect(InetSocketAddress(serverHost, serverPort), 10000)  // 10s timeout
            }
            socket = clientSocket
            writer = PrintWriter(
                OutputStreamWriter(socket?.getOutputStream(), Charsets.UTF_8),
                true // auto-flush
            )
            reader = BufferedReader(
                InputStreamReader(
                    socket?.getInputStream(),
                    Charsets.UTF_8
                )
            )
            
            isConnected.set(true)
            shouldReconnect.set(true)
            
            Log.i(TAG, "Connected successfully")
            listener.onConnectionChanged(true)
            
            // Gửi message khởi tạo
            sendCommand("CLIENT_CONNECTED")
            
            // Start listening for responses
            startListening()
            
        }catch(e: SocketTimeoutException){
            Log.d(TAG, "Connection timed out")
            isConnected.set(false)
            listener.onConnectionChanged(false)
            listener.onError("Connection failed: ${e.message}")
        }
```

Hoạt động:
- Kiểm tra nếu đã kết nối, trả về
- Tạo Socket mới với các option:
  - `keepAlive = true`: Giữ kết nối sống bằng TCP keepalive packets
  - `tcpNoDelay = true`: Gửi dữ liệu ngay lập tức, không chờ buffer
  - `soTimeout = 0`: Không có timeout khi đọc dữ liệu
- Kết nối đến server với timeout 10 giây
- Tạo PrintWriter và BufferedReader cho I/O
- Đặt `isConnected = true` và thông báo listener
- Gửi "CLIENT_CONNECTED" cho server
- Bắt đầu lắng nghe responses

*b. disconnect() - Ngắt Kết nối*

Phương thức này đóng kết nối một cách graceful.

```kotlin
fun disconnect(){
    if(!isConnected.get()){
        Log.d(TAG, "Không có kết nối nào")
        return
    }
    executor.execute {
        try{
            isConnected.set(false)
            
            writer?.close()
            reader?.close()
            socket?.close()
            
            Log.i(TAG, "Ngắt kết nối thành công")
            listener.onConnectionChanged(false)
        }catch (e: Exception){
            Log.e(TAG, "Lỗi ngắt kết nối: ${e.message}", e)
        }
    }
}
```

Hoạt động:
- Kiểm tra nếu không kết nối, trả về
- Đặt `isConnected = false`
- Đóng PrintWriter, BufferedReader, Socket theo thứ tự
- Thông báo listener về việc ngắt kết nối

\
*c. sendCommand() - Gửi Lệnh đến Server*

Phương thức này gửi một lệnh tới server.

```kotlin
fun sendCommand(command: String){
    if(!isConnected.get()){
        Log.d(TAG,"No Connection")
        return
    }
    
    executor.execute {
        try{
            writer?.println(command)
            Log.d(TAG, "Command sent: $command")
        } catch(e: Exception){
            Log.e(TAG, "Failed to send command: $command", e)
            handleConnectionError(e)
        }
    }
}
```

Hoạt động:
- Kiểm tra nếu không kết nối, trả về
- Gửi lệnh thông qua PrintWriter (tự động thêm newline)
- Ghi log lệnh được gửi
- Nếu có exception, xử lý connection error

*d. startListening() - Lắng nghe Responses từ Server*

Phương thức này lắng nghe các thông báo từ server trong một vòng lặp.
\
\
\
\
\
\
\
\
\
\
\
\
\

```kotlin
private fun startListening() {
    executor.execute {
        try {
            while (isConnected.get() && !Thread.currentThread().isInterrupted) {
                val message = reader?.readLine()
                
                if (message == null) {
                    Log.w(TAG, "Server closed connection")
                    handleConnectionError(SocketException("Connection closed by server"))
                    break
                }
                
                Log.d(TAG, "Message received: $message")
                handleServerMessage(message)
                if(!isConnected.get()){
                    break
                }
            }
        } catch (e: SocketException) {
            if (isConnected.get()) {
                Log.e(TAG, "Socket error while listening", e)
                handleConnectionError(e)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error while listening", e)
            handleConnectionError(e)
        } finally{
            disconnect()
        }
    }
}
```

Hoạt động:
- Vòng lặp liên tục đọc messages từ server
- Nếu message là null (server đã đóng), xử lý connection error
- Nếu nhận được message, gọi `handleServerMessage()`
- Xử lý các exception (SocketException, Exception chung)
- Finally block đảm bảo disconnect được gọi
\
\
\

*e. handleServerMessage() - Xử lý Thông báo từ Server*

Phương thức này xử lý các thông báo nhận được từ server.

```kotlin
private fun handleServerMessage(message: String){
    when{
        message == "SERVER_SHUTDOWN" -> {
            Log.d(TAG, "Server is shutting down")
            listener.onStatusUpdate("Server has stopped")
            listener.onError("Server stopped - connection closed")
        }
        message.startsWith("Error") ->{
            val error = message.substringAfter("Error")
            listener.onError(error)
        }
        message == "PHOTO_TAKEN" -> {
            listener.onStatusUpdate("Photo captured successfully")
        }
        message == "RECORDING_STARTED" -> {
            listener.onStatusUpdate("Video recording started")
        }
        message == "RECORDING_STOPPED" -> {
            listener.onStatusUpdate("Video recording stopped")
        }
        else -> {
            listener.onMessageReceived(message)
        }
    }
}
```

Hoạt động:
- Kiểm tra các thông báo đặc biệt từ server
- "SERVER_SHUTDOWN": Server đang tắt
- "Error...": Thông báo lỗi từ server
- "PHOTO_TAKEN": Ảnh đã được chụp
- "RECORDING_STARTED": Quay video bắt đầu
- "RECORDING_STOPPED": Quay video dừng
- Thông báo khác được gửi qua onMessageReceived
\
\
\
\
\

*f. Camera Command Methods - Gửi Lệnh Camera*

```kotlin
fun takePhoto() = sendCommand("TAKE_PHOTO")
fun stopVideoRecording() = sendCommand("RECORD")
fun startVideoRecording() = sendCommand("RECORD")
fun switchCamera() = sendCommand("SWITCH_CAMERA")
```

Hoạt động:
- Các convenience methods để gửi các lệnh camera phổ biến
- Dễ dàng mở rộng thêm các lệnh khác

*g. shutdown() - Tắt Client một cách Graceful*

Phương thức này tắt client và đóng tất cả resources.

```kotlin
fun shutdown() {
    disconnect()
    executor.shutdown()
    scheduledExecutor.shutdown()
    
    try {
        if (! executor.awaitTermination(5, TimeUnit.SECONDS)) {
            executor.shutdownNow()
        }
        if (!scheduledExecutor.awaitTermination(5, TimeUnit.SECONDS)) {
            scheduledExecutor.shutdownNow()
        }
    } catch (e: InterruptedException) {
        Log.e(TAG, "Interrupted while waiting for executor to shutdown", e)
        executor.shutdownNow()
        scheduledExecutor.shutdownNow()
    }
}
```

Hoạt động:
- Gọi `disconnect()` để ngắt kết nối
- Shutdown các executor
- Chờ tối đa 5 giây cho executor kết thúc gracefully
- Nếu vẫn còn task, gọi `shutdownNow()` để force shutdown
\
\
\
\

*h.CameraClientListener Interface*

Interface này định nghĩa các callback cho client:

```kotlin
interface CameraClientListener {
  fun onConnectionChanged(isConnected: Boolean)  // Khi kết nối thay đổi
  fun onMessageReceived(message: String)       // Khi nhận message chung
  fun onStatusUpdate(status: String)       // Khi nhận status update     
  fun onError(error: String)                     // Khi có lỗi xảy ra
  fun onError(error: String)                     // Khi có lỗi xảy ra
}
```
*Quy trình hoạt động tổng thể*

1. Tạo instance CameraSocketClient với server host/port
2. Gọi `connect()` để kết nối đến server
3. Client gửi "CLIENT_CONNECTED" cho server
4. Server gửi "CONNECTED_TO_SERVER" xác nhận
5. Client bắt đầu `startListening()` trong background thread
6. Người dùng gọi `takePhoto()`, `startVideoRecording()`, v.v.
7. Client gửi lệnh qua Server
8. Server nhận lệnh và xử lý
9. Server gửi responses (PHOTO_TAKEN, RECORDING_STARTED, v.v.)
10. Client nhận responses và gọi callback listener
11. Gọi `shutdown()` khi kết thúc

