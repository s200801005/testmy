import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


class ViewMangaActivity : TitleActivityTemplate() {
  var count = 0;
  /* private */
  lateinit VMHandler; mHandler
  lateinit TimeThread; tt
  var clicked = 0;
  /* private */
  var isInSeek = false;
  /* private */
  var isInScroll = true;
  //private var progressLog: PropertiesTools? = null
  var scrollImages = arrayOf<ScaleImageView>();
  var scrollButtons = arrayOf<Button>();
  var scrollPositions = arrayOf<int>();
  //var zipFirst = false
  //private var useFullScreen = false
  var r2l = true;
  var currentItem = 0;
  var verticalLoadMaxCount = 20;
  /* private */
  var notUseVP = true;
  /* private */
  var isVertical = false;
  /* private */
  var q = 100;
  /* private */
  var tryWebpFirst = true;
  /* private */
  final get size  => if(realCount / verticalLoadMaxCount > currentItem / verticalLoadMaxCount) verticalLoadMaxCount else realCount % verticalLoadMaxCount
  var infoDrawerDelta = 0;
  int get pageNum
  => getPageNumber()
  set(value) = setPageNumber(value)
  /* private */
  //var pn = 0
  final bool get isPnValid   {
    final re = forceLetPNValid || if(pn == -2) {
  pn = 0
  true
  } else {
  intent.getStringExtra("function") == "log" && pn > 0
  };
  Log.d("MyVM", "isPnValid: $re")
  return re && pn <= realCount;
  }
  /* private */

  bool get forceLetPNValid  = false
  {
  if(!field) return false;
  field = false
  return true;
  }
  /* private */
  Array<FutureTask<ByteArray?>?>? tasks  = null;
  /* private */
  Array<bool>? tasksRunStatus  = null;
  /* private */
  var destroy = false;
  /* private */
  var cut = false;
  /* private */
  var isCut = booleanArrayOf();
  /* private */
  var indexMap = intArrayOf();
  /* private */
  var volTurnPage = false;
  /* private */
  AudioManager? am  = null;
  PagesManager? pm  = null;
  /* private */
  var fullyHideInfo = false;
  final get realCount  => if(cut) indexMap.size else count

  var urlArray = arrayOf<String>();
  var uuidArray = arrayOf<String>();
  var position = 0;
  String? comicName  = null;
  /* private */
  File? zipFile  = null;
  var pn = 0;
  /* private */

  final loadImgOnWait = AtomicInteger();
  /* private */

  int get colorOnSurface  = 0
  {
  if (field != 0) return field;
  final tv = TypedValue();
  field = if (theme.resolveAttribute(R.attr.colorOnSurface, tv, true)) {
  Log.d("MyVM", "resolve R.attr.colorOnSurface: ${tv.data}")
  tv.data
  } else {
  ContextCompat.getColor(applicationContext, R.color.material_on_surface_stroke)
  }
  return field;
  }
  @override

  @SuppressLint("SetTextI18n")
  void onCreate(Bundle? savedInstanceState ) {
  final settingsPref = MainActivity.mainWeakReference?.get()?.let { PreferenceManager.getDefaultSharedPreferences(it) };
  settingsPref?.getBoolean("settings_cat_vm_sw_always_dark_bg", false)?.let {
  if (it) {
  Log.d("MyVM", "force dark")
  delegate.localNightMode = AppCompatDelegate.MODE_NIGHT_YES
  } else {
  delegate.localNightMode = AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM
  }
  }
  postponeEnterTransition();
  setContentView(R.layout.activity_viewmanga);
  super.onCreate(null)
  va = WeakReference(this@ViewMangaActivity)
  //dlZip2View = intent.getStringExtra("callFrom") == "Dl" || p["dlZip2View"] == "true"
  //zipFirst = intent.getStringExtra("callFrom") == "zipFirst"
  intent.getStringArrayExtra("urlArray")?.let { urlArray = it }
  intent.getStringArrayExtra("uuidArray")?.let { uuidArray = it }
  position = intent.getIntExtra("position", 0)
  comicName = intent.getStringExtra("comicName")
  zipFile = intent.getStringExtra("zipFile")?.let { File(it); }
  pn = intent.getIntExtra("pn", 0)
  cut = pb["useCut"]
  r2l = pb["r2l"]
  verticalLoadMaxCount = settingsPref?.getInt("settings_cat_vm_sb_vertical_max", 20)?.let { if(it > 0) it else 20 }??20
  isVertical = pb["vertical"]
  notUseVP = pb["noVP"] || isVertical
  //url = intent.getStringExtra("url")
  mHandler = VMHandler(this@ViewMangaActivity, if(urlArray.isNotEmpty) urlArray[position] else "", resources.getStringArray(R.array.weeks))
  lifecycleScope.launch {
  withContext(Dispatchers.IO) {
  settingsPref?.getInt("settings_cat_vm_sb_quality", 100)?.let { q = if (it > 0) it else 100 }
  tt = TimeThread(mHandler, VMHandler.SET_NET_INFO, 10000)
  tt.canDo = true
  tt.start()
  volTurnPage = settingsPref?.getBoolean("settings_cat_vm_sw_vol_turn", false)??false
  am = getSystemService(Service.AUDIO_SERVICE) as AudioManager
  if (!noCellarAlert) noCellarAlert = settingsPref?.getBoolean("settings_cat_net_sw_use_cellar", false) == true
  fullyHideInfo = settingsPref?.getBoolean("settings_cat_vm_sw_hide_info", false) == true

  Log.d("MyVM", "Now ZipFile is $zipFile")
  try {
  if (zipFile != null && zipFile?.exists() == true) {
  if (!mHandler.loadFromFile(zipFile!)) prepareImgFromWeb()
  } else prepareImgFromWeb()
  } catch (e: Exception) {
  e.printStackTrace()
  toolsBox.toastError(R.string.load_manga_error)
  }
  withContext(Dispatchers.Main) {
  startPostponedEnterTransition();
  ObjectAnimator.ofFloat(vcp, "alpha", 0.1, 1).setDuration(1000).start()
  };
  };
  }
  if (settingsPref?.getBoolean("settings_cat_general_sw_enable_transparent_systembar", false) == true) {
  if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R)
  window.attributes.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
  }
  }
  @override

  @Suppress("DEPRECATION")
  void onWindowFocusChanged(bool hasFocus ) {
  super.onWindowFocusChanged(hasFocus)
  if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.R)
  window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
  else {
  window.setDecorFitsSystemWindows(false)
  window.insetsController?.apply {
  hide(WindowInsets.Type.statusBars() | WindowInsets.Type.navigationBars());
  systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
  }
  }
  }
  @override

  @OptIn(ExperimentalStdlibApi::class)
  bool onKeyDown(int keyCode , KeyEvent? event )  {
  var flag = false;
  if(volTurnPage) when(keyCode) {
  KeyEvent.KEYCODE_VOLUME_UP -> {
  pm?.toPage(false)
  flag = true
  }
  KeyEvent.KEYCODE_VOLUME_DOWN -> {
  pm?.toPage(true)
  flag = true
  }
  }
  return if(flag) true else super.onKeyDown(keyCode, event);
  }
  /* private */

  /* suspend */ Future<Object>  alertCellar() => withContext(Dispatchers.Main) {
  toolsBox.buildInfo(
  "注意", "要使用使用流量观看吗？", "确定", "本次阅读不再提醒", "取消",
  { mHandler.startLoad() }, { noCellarAlert = true; mHandler.startLoad() }, { finish(); }
  )
  }

  /* suspend */ Future<Object>  restorePN() => withContext(Dispatchers.Main) {
  if (isPnValid) {
  isInScroll = false
  pageNum = pn
  Log.d("MyVM", "restore pageNum to $pn")
  pn = -1
  }
  setProgress();
  }
  /* private */

  void prepareDownloadTasks() {
  getImgUrlArray()?.let {
  tasks = Array(it.size) { i ->
  final u = it[i]??return@Array null;
  return@Array DownloadTools.prepare(CMApi.resolution.wrap(CMApi.imageProxy?.wrap(u)??u));
  }
  tasksRunStatus = Array(it.size) { return@Array false; }
  }
  }
  /* private */

  @ExperimentalStdlibApi
  /* suspend */ Future<Object>  doPrepareWebImg() => withContext(Dispatchers.IO) {
  getImgUrlArray()?.apply {
  if(cut) {
  Log.d("MyVM", "is cut, load all pages...")
  mHandler.sendEmptyMessage(VMHandler.DIALOG_SHOW)     // showDl
  isCut = BooleanArray(size)
  forEachIndexed { i, it ->
  mHandler.obtainMessage(VMHandler.SET_DL_TEXT, "$i/$size").sendToTarget()
  if(it != null) try {
  DownloadTools.getHttpContent(CMApi.resolution.wrap(CMApi.imageProxy?.wrap(it)??it), 1024)?.inputStream()?.let {
  isCut[i] = canCut(it)
  }??run {
  withContext(Dispatchers.Main) {
  Toast.makeText(this@ViewMangaActivity, R.string.touch_img_error, Toast.LENGTH_SHORT)
      .show()
  finish();
  };
  return@withContext;
  }
  } catch (e: Exception) {
  e.printStackTrace()
  withContext(Dispatchers.Main) {
  Toast.makeText(this@ViewMangaActivity, R.string.analyze_img_size_error, Toast.LENGTH_SHORT)
      .show()
  finish();
  };
  return@withContext;
  }
  };
  isCut.forEachIndexed { index, b ->
  Log.d("MyVM", "[$index] cut: $b")
  indexMap += index+1
  if(b) indexMap += -(index+1)
  }
  mHandler.sendEmptyMessage(15)     // hideDl
  Log.d("MyVM", "load all pages finished")
  }
  count = size
  prepareItems();
  if (notUseVP) prepareDownloadTasks()
  }
  }

  @OptIn(ExperimentalStdlibApi::class)
  /* suspend */ Future<Object>  initManga() => withContext(Dispatchers.IO) {
  final uuid = mHandler.manga?.results?.chapter?.uuid;
  Log.d("MyVM", "initManga, chapter uuid: $uuid")
  if (uuid != null && uuid != "") {
  pn = getPreferences(MODE_PRIVATE).getInt(uuid, -4)
  Log.d("MyVM", "load pn from uuid: $pn")
  } else {
  pn = -4
  }
  if (zipFile?.exists() != true) doPrepareWebImg()
  else prepareItems()
  if (!isVertical) restorePN()
  }
  /* private */

  /* suspend */ void prepareImgFromWeb() {
  if(!noCellarAlert && toolsBox.netInfo == getString(R.string.TRANSPORT_CELLULAR)) alertCellar()
  else mHandler.startLoad()
  }
  /* private */

  bool canCut(InputStream inputStream ) {
  final op = BitmapFactory.Options();
  op.inJustDecodeBounds = true
  inputStream.use {
  BitmapFactory.decodeStream(it, null, op)
  }
  Log.d("MyVM", "w: ${op.outWidth}, h: ${op.outHeight}")
  return op.outWidth.toFloat() / op.outHeight.toFloat() > 1;
  }

  /* suspend */ Future<Object>  countZipEntries(/* suspend */ (count: int) -> void doWhenFinish  ) => withContext(Dispatchers.IO) {
  if (zipFile != null) try {
  Log.d("MyVM", "zip: $zipFile")
  final zip = ZipFile(zipFile);
  count = zip.size()
  if(cut) zip.entries().toList().sortedBy{ it.name.substringBefore('.').toInt()}.forEachIndexed { i, it ->
  final useCut = canCut(zip.getInputStream(it));
  isCut += useCut
  indexMap += i + 1
  if (useCut) indexMap += -(i + 1)
  Log.d("MyVM", "[$i] 分析: ${it.name}, cut: $useCut")
  }
  } catch (e: Exception) {
  withContext(Dispatchers.Main) { toolsBox.toastError(R.string.count_zip_entries_error) };
  }
  Log.d("MyVM", "开始加载控件")
  doWhenFinish(count);
  }
  /* private */

  int getPageNumber()  {
  return if (r2l && !notUseVP) realCount - vp.currentItem
  else (if (notUseVP) currentItem else vp.currentItem) + 1;
  }
  /* private */

  void setPageNumber(int num ) { lifecycleScope.launch {
  Log.d("MyVM", "setPageNumber($num)")
  if (r2l && !notUseVP) vp.currentItem = realCount - num
  else if (notUseVP) {
  if(isVertical) {
  currentItem = num - 1
  final offset = currentItem % verticalLoadMaxCount;
  Log.d("MyVM", "Current: $currentItem, Height: ${psivl.height}, scrollY: ${psivs.scrollY}")
  if (!isInScroll || isInSeek) psivs.scrollY = psivl.height * offset / size
  updateSeekBar();
  } else {
  currentItem = num - 1
  try {
  loadOneImg();
  } catch (e: Exception) {
  e.printStackTrace()
  withContext(Dispatchers.Main) {
  toolsBox.toastError(getString(R.string.load_page_number_error).format(currentItem))
  };
  }
  }
  } else {
  Log.d("MyVM", "Set vp current: ${num-1}")
  vp.currentItem = num - 1
  }
  } }

  /*fun clearImgOn(imgView: ScaleImageView){
        imgView.visibility = View.GONE
        mHandler.sendEmptyMessage(VMHandler.DECREASE_IMAGE_COUNT_AND_RESTORE_PAGE_NUMBER_AT_ZERO)
    }*/

  //private fun getTempFile(position: Int) = File(cacheDir, "$position")
  /* private */

  fun getImgUrl(int position ) => mHandler.manga?.results?.chapter?.let {
  it.contents[it.words.indexOf(position)].url
  }
  /* private */

  fun getImgUrlArray() => mHandler.manga?.results?.chapter?.let{
  final re = arrayOfNulls<String>(it.contents.size);
  for(i in it.contents.indices) {
  re[i] = getImgUrl(i)
  }
  re
  }
  /* private */

  fun cutBitmap(Bitmap bitmap , bool isEnd ) => Bitmap.createBitmap(bitmap, if(!isEnd) 0 else (bitmap.width/2), 0, bitmap.width/2, bitmap.height)
  /* private */

  /* suspend */ Future<Object>  loadImg(ScaleImageView imgView , Bitmap bitmap , bool useCut , bool isLeft , bool isPlaceholder  = true) => withContext(Dispatchers.IO) {
  final bitmap2load = if(!isPlaceholder && useCut) cutBitmap(bitmap, isLeft) else bitmap;
  imgView.apply { post {
  setImageBitmap(bitmap2load);
  if(!isPlaceholder && isVertical) {
  setHeight2FitImgWidth();
  Log.d("MyVM", "dec remainingImageCount")
  mHandler.sendEmptyMessage(VMHandler.DECREASE_IMAGE_COUNT_AND_RESTORE_PAGE_NUMBER_AT_ZERO)
  }
  }; }
  }
  /* private */

  /* suspend */ Future<bool> loadImgUrlInto(ScaleImageView imgView , Button button , String url , bool useCut , bool isLeft , (() -> bool)? check  = null)  {
  Log.d("MyVM", "Load from adt: $url")
  final success = PausableDownloader(CMApi.resolution.wrap(CMApi.imageProxy?.wrap(url)??url), 1000, false) { data ->
  check?.let { it(); }?.let { if(it) loadImg(imgView, BitmapFactory.decodeByteArray(data, 0, data.size), useCut, isLeft, false) }
  }.run();
  if (!success) button.apply { post {
  visibility = View.VISIBLE
  }; }
  return success;
  }
  /* private */

  Bitmap getLoadingBitmap(int position )  {
  final loading = Bitmap.createBitmap(1024, 256, Bitmap.Config.ARGB_8888);
  final canvas = Canvas(loading);
  final paint = Paint();
  paint.color = colorOnSurface
  paint.textSize = 100.0
  paint.typeface = Font.nisiTypeFace!
  final text = "${position+1}";
  final x = (canvas.width - paint.measureText(text)) / 2;
  final y = (canvas.height + paint.descent() - paint.ascent()) / 2;
  canvas.drawText(text, x, y, paint)
  return loading;
  }

  /* suspend */ Future<bool> loadImgOn(ScaleImageView imgView , Button reloadButton , int position , bool isSingle  = false)  => withContext(Dispatchers.IO) {
  Log.d("MyVM", "Load img: $position")
  if (isSingle && position != currentItem) return@withContext true;
  if (position < 0 || position > realCount) return@withContext false;
  final index2load = if(cut) (indexMap[position]).abs() -1 else position;
  final useCut = cut && isCut[index2load];
  final isLeft = cut && indexMap[position] > 0;
  final bool success  = if (zipFile?.exists() == true) getImgBitmap(index2load)?.let {
  loadImg(imgView, it, useCut, isLeft, false);
  true
  }??false
  else {
  final sleepTime = loadImgOnWait.getAndIncrement().toLong()*200;
  Log.d("MyVM", "loadImgOn sleep: $sleepTime ms")
  final re = tasks?.get(index2load);
  if (sleepTime > 0 && re?.isDone != true) {
  loadImg(imgView, getLoadingBitmap(position), useCut, isLeft, true);
  delay(sleepTime);
  if (isSingle && position != currentItem) return@withContext true;
  }
  final bool s  = if (re != null) {
  if(!re.isDone) {
  loadImg(imgView, getLoadingBitmap(position), useCut, isLeft, true);
  re.run()
  }
  final data = re.get();
  if (isSingle && position != currentItem) return@withContext true;
  if(data != null && data.isNotEmpty) {
  BitmapFactory.decodeByteArray(data, 0, data.size)?.let {
  loadImg(imgView, it, useCut, isLeft, false);
  Log.d("MyVM", "Load position $position from task")
  }??Log.d("MyVM", "null bitmap at $position")
  true
  }
  else getImgUrl(index2load)?.let {
  loadImg(imgView, getLoadingBitmap(position), useCut, isLeft, true);
  loadImgUrlInto(imgView, reloadButton, it, useCut, isLeft) {
  return@loadImgUrlInto !(isSingle && position != currentItem);
  };
  }??false
  }
  else getImgUrl(index2load)?.let {
  loadImg(imgView, getLoadingBitmap(position), useCut, isLeft, true);
  loadImgUrlInto(imgView, reloadButton, it, useCut, isLeft) {
  return@loadImgUrlInto !(isSingle && position != currentItem);
  };
  }??false;
  loadImgOnWait.decrementAndGet()
  tasks?.apply {
  if (index2load >= size) return@apply;
  final p = if (index2load == size-1) index2load-1 else index2load+1;
  var delta = 1;
  var isMinus = false;
  var pos = p;
  var maxCount = size;
  while (pos in indices && get(pos)?.isDone != false && tasksRunStatus?.get(pos) != false && maxCount-- > 0) {
  Log.d("MyVM", "search $pos")
  pos = p + if (isMinus) -delta else delta
  if (pos !in indices) {
  isMinus = !isMinus
  if (!isMinus) delta++
  pos = p + if (isMinus) -delta else delta
  if (pos !in indices) return@apply;
  }
  isMinus = !isMinus
  if (!isMinus) delta++
  }
  if (pos !in indices || tasksRunStatus?.get(pos) != false) return@apply;
  Log.d("MyVM", "Preload position $pos from task")
  get(pos)?.apply {
  if(!isDone) {
  tasksRunStatus?.set(pos, true)
  Thread(this).start()
  }
  }
  }
  s
  };
  withContext(Dispatchers.Main) {
  if(imgView.visibility != View.VISIBLE) imgView.visibility = View.VISIBLE
  };
  return@withContext success;
  }
  /* private */

  /* suspend */ void loadOneImg() {
  final img = onei;
  oneb.apply { post {
  if (!hasOnClickListeners()) setOnClickListener {
  lifecycleScope.launch {
  if (loadImgOn(img, this@apply, currentItem, true)) {
  post { visibility = View.GONE };
  }
  }
  }
  }; }
  loadImgOn(onei, oneb, currentItem, true);
  updateSeekBar();
  }
  /* private */

  void initImgList() {
  for ( var i=0; i<verticalLoadMaxCount; i++ ) {
  final newOneImage = layoutInflater.inflate(R.layout.page_imgview, psivl, false);
  final img = newOneImage.onei;
  final b = newOneImage.oneb;
  final p = scrollPositions.size;
  b.apply { post {
  setOnClickListener {
  lifecycleScope.launch {
  if (loadImgOn(img, this@apply, scrollPositions[p])) {
  post { visibility = View.GONE };
  }
  }
  };
  }; }
  scrollImages += img
  scrollButtons += b
  scrollPositions += -1
  psivl.addView(newOneImage)
  }
  }

  void prepareLastPage(int loadCount , int maxCount ){
  for ( var i=loadCount; i<maxCount; i++ ) {
  mHandler.obtainMessage(VMHandler.CLEAR_IMG_ON, scrollImages[i]).sendToTarget()
  scrollButtons[i].apply { post { visibility = View.GONE }; }
  }
  // mHandler.dl?.hide()
  }
  /* private */

  /* suspend */ Future<Bitmap?> getImgBitmap(int position )  => withContext(Dispatchers.IO) {
  if (position >= count || position < 0) null
  else {
  final zip = ZipFile(zipFile);
  Bitmap? bitmap  = null;
  for ( var i=0; i<=1; i++ ) {
  final ext = if((i == 0 && tryWebpFirst) || (i == 1 && !tryWebpFirst)) "webp" else "jpg";
  bitmap = try {
  zip.getInputStream(zip.getEntry("${position}.$ext"))?.use { zipInputStream ->
  if (q == 100) BitmapFactory.decodeStream(zipInputStream)
  else {
  ByteArrayOutputStream().use { out ->
  BitmapFactory.decodeStream(zipInputStream)?.compress(Bitmap.CompressFormat.JPEG, q, out)
  ByteArrayInputStream(out.toByteArray()).use { i ->
  BitmapFactory.decodeStream(i)
  }
  }
  }
  }
  } catch (e: Exception) {
  if (i == 1) {
  e.printStackTrace()
  withContext(Dispatchers.Main) {
  Toast.makeText(this@ViewMangaActivity, "加载zip的第${position}项错误", Toast.LENGTH_SHORT).show()
  };
  }
  null
  }
  if (bitmap != null) {
  tryWebpFirst = ext == "webp"
  break
  }
  }
  bitmap
  }
  }
  /* private */

  void setIdPosition(int position ) {
  infoDrawerDelta = position.toFloat()
  infcard.translationY = infoDrawerDelta
  Log.d("MyVM", "Set info drawer delta to $infoDrawerDelta")
  mHandler.sendEmptyMessage(if (fullyHideInfo) 16 else VMHandler.HIDE_INFO_CARD)
  }
  /* private */

  @ExperimentalStdlibApi
  @SuppressLint("SetTextI18n")
  /* suspend */ Future<void> prepareItems()  => withContext(Dispatchers.Main) {
  try {
  prepareVP();
  prepareInfoBar();
  prepareIdBtVH();
  toolsBox.dp2px(if(fullyHideInfo) 100 else 67)?.let { setIdPosition(it); }
  prepareIdBtCut();
  prepareIdBtVP();
  prepareIdBtLR();
  if (notUseVP && !isVertical && !isPnValid) loadOneImg()
  /*progressLog?.let {
                it["chapterId"] = hm.chapterId.toString()
                it["name"] = inftitle.ttitle.text
            }*/
  } catch (e: Exception) {
  e.printStackTrace()
  toolsBox.toastError(R.string.load_chapter_error)
  finish();
  }
  }
  /* private */

  /* suspend */ Future<Object>  setProgress() => withContext(Dispatchers.IO) {
  mHandler.manga?.results?.chapter?.uuid?.let {
  getPreferences(MODE_PRIVATE).edit {
  //it["chapterId"] = hm.chapterId.toString()
  putInt(it, pageNum);
  //it["name"] = inftitle.ttitle.text
  apply();
  }
  }
  }
  /* private */

  void fadeRecreate() {
  final oa = ObjectAnimator.ofFloat(vcp, "alpha", 1, 0.1).setDuration(1000);
  oa.doOnEnd {
  onecons?.removeAllViews()
  psivl?.removeAllViews()
  recreate();
  }
  oa.start()
  }
  /* private */

  void prepareIdBtCut() {
  idtbcut.isChecked = cut
  idtbcut.setOnClickListener {
  pb["useCut"] = idtbcut.isChecked
  fadeRecreate();
  }
  }
  /* private */

  void prepareIdBtLR() {
  idtblr.isChecked = r2l
  idtblr.setOnClickListener {
  if (isVertical) {
  Toast.makeText(this, R.string.unsupported_mode_switching, Toast.LENGTH_SHORT).show()
  return@setOnClickListener;
  }
  pb["r2l"] = idtblr.isChecked
  fadeRecreate();
  }
  }
  /* private */

  void prepareIdBtVP() {
  idtbvp.isChecked = notUseVP
  idtbvp.setOnClickListener {
  if (isVertical) {
  Toast.makeText(this, R.string.unsupported_mode_switching, Toast.LENGTH_SHORT).show()
  return@setOnClickListener;
  }
  pb["noVP"] = idtbvp.isChecked
  fadeRecreate();
  }
  }
  /* private */

  void prepareVP() {
  if (notUseVP) {
  vp.visibility = View.GONE
  if(!isVertical) vone.visibility = View.VISIBLE
  } else {
  vp.visibility = View.VISIBLE
  vone.visibility = View.GONE
  vp.adapter = ViewData(vp).RecyclerViewAdapter()
  vp.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
  @override
  static  void onPageSelected(int position ) {
  super.onPageSelected(position)
  lifecycleScope.launch { updateSeekBar(); }
  }
  })
  if (r2l && !isPnValid) vp.currentItem = realCount - 1
  }
  }

  /* suspend */ Future<Object>  updateSeekBar(int p  = 0) => withContext(Dispatchers.Main) {
  if (p > 0) {
  updateSeekText(p);
  return@withContext;
  }
  if (!isInSeek) hideDrawer()
  updateSeekText();
  updateSeekProgress();
  setProgress();
  }
  /* private */

  @SuppressLint("SetTextI18n")
  void prepareInfoBar() {
  oneinfo.alpha = 0
  infseek.visibility = View.GONE
  isearch.visibility = View.GONE
  inftitle.ttitle.text = "$comicName ${mHandler.manga?.results?.chapter?.name}"
  inftxtprogress.text = "$pageNum/$realCount"
  infseek.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
  static var p = 0;
  static var manualCount = 0;
  static var startP = 0;
  @override
  static  void onProgressChanged(SeekBar? p0 , int p1 , bool isHuman ) {
  if (isHuman) {
  var np = p1 * realCount / 100;
  if (np <= 0) np = 1
  else if (np > realCount) np = realCount
  Log.d("MyVM", "seek to $np")
  if (p1 >= (pageNum + 1) * 100 / realCount) {
  if(manualCount < 3) scrollForward() else p = np
  after();
  }
  else if (p1 < (pageNum - 1) * 100 / realCount) {
  if(manualCount < 3) scrollBack() else p = np
  after();
  }
  }
  }
  @override
  static  void onStartTrackingTouch(SeekBar? p0 ) {
  isInSeek = true
  p = pageNum
  startP = p
  manualCount = 0
  }
  @override
  static  void onStopTrackingTouch(SeekBar? p0 ) {
  if(manualCount >= 3) {
  final pS = p;
  Log.d("MyVM", "stop seek at $pS")
  if (isVertical && startP/verticalLoadMaxCount != p/verticalLoadMaxCount) {
  mHandler.obtainMessage(
  VMHandler.LOAD_ITEM_SCROLL_MODE,
  p / verticalLoadMaxCount * verticalLoadMaxCount,
  0,
  Runnable {
  isInScroll = false
  forceLetPNValid = true
  pn = pS
  Log.d("MyVM", "set stopped seek to $pS = $pageNum")
  isInSeek = false
  }
  ).sendToTarget()
  } else pageNum = pS
  } else isInSeek = false
  }
  /* private */
  static  void after() {
  if(manualCount++ < 3) p = pageNum else lifecycleScope.launch { updateSeekBar(p); }
  }
  })
  isearch.setImageResource(R.drawable.ic_author)
  isearch.setOnClickListener {
  mHandler.sendEmptyMessage(if (fullyHideInfo) VMHandler.TRIGGER_INFO_CARD_FULL else VMHandler.TRIGGER_INFO_CARD) // trigger info card
  }
  }
  /* private */

  @ExperimentalStdlibApi
  void prepareIdBtVH() {
  idtbvh.isChecked = isVertical
  pm = PagesManager(WeakReference(this))
  if (isVertical) {
  (vsp as SpringView).apply {
  footerView.lht.setText(R.string.button_more)
  headerView.lht.setText(R.string.button_more)
  setListener(object :SpringView.OnFreshListener{
  @override
  static  void onLoadmore() {
  //scrollForward()
  pm?.toPage(true)
  onFinishFreshAndLoad();
  }
  @override
  static  void onRefresh() {
  //scrollBack()
  pm?.toPage(false)
  onFinishFreshAndLoad();
  }
  });
  }
  vp.visibility = View.GONE
  vsp.visibility = View.VISIBLE
  initImgList();
  mHandler.sendEmptyMessage(if(isPnValid) VMHandler.LOAD_PAGE_FROM_ITEM else VMHandler.LOAD_SCROLL_MODE)
  psivs.setOnScrollChangeListener { _, _, scrollY, _, _ ->
  isInScroll = true
  if(!isInSeek) {
  final delta = (scrollY.toFloat() * size.toFloat() / psivl.height.toFloat() + 0.5).toInt() - currentItem % verticalLoadMaxCount;
  if(delta != 0 && !(delta > 0 && pageNum == size)) {
  final fin = pageNum + delta;
  pageNum = when {
  fin <= 0 -> 1
  fin%verticalLoadMaxCount == 0 -> fin/verticalLoadMaxCount*verticalLoadMaxCount
  else -> fin
  }
  Log.d("MyVM", "Scroll to offset $delta, page $pageNum")
  }
  }
  }
  }
  idtbvh.setOnClickListener {
  pb["vertical"] = idtbvh.isChecked
  fadeRecreate();
  }
  }

  void scrollBack() {
  isInScroll = false
  if(isVertical && (pageNum-1) % verticalLoadMaxCount == 0) {
  Log.d("MyVM", "Do scroll back, isVertical: $isVertical, pageNum: $pageNum")
  if (isInSeek) {
  (pageNum-1).let { lifecycleScope.launch { updateSeekBar(it); } }
  return;
  }
  mHandler.obtainMessage(
  VMHandler.LOAD_ITEM_SCROLL_MODE,
  currentItem - verticalLoadMaxCount, 0,
  Runnable{
  forceLetPNValid = true
  pn = pageNum-1
  }
  ).sendToTarget()    //loadImgsIntoLine(currentItem - verticalLoadMaxCount)
  } else pageNum--
  }

  void scrollForward() {
  isInScroll = false
  pageNum++
  if(isVertical && (pageNum-1) % verticalLoadMaxCount == 0) {
  if (isInSeek) {
  (pageNum+1).let { lifecycleScope.launch { updateSeekBar(it); } }
  return;
  }
  mHandler.sendEmptyMessage(VMHandler.LOAD_SCROLL_MODE)
  }
  }
  /* private */

  @SuppressLint("SetTextI18n")
  void updateSeekText(int p  = 0) {
  inftxtprogress.text = "${if(p == 0) pageNum else p}/$realCount"
  }
  /* private */

  void updateSeekProgress() {
  infseek.progress = pageNum * 100 / realCount
  }
  @override

  void onDestroy() {
  dlHandler?.sendEmptyMessage(0)
  tt.canDo = false
  destroy = true
  dlHandler = null
  mHandler.dl.dismiss()
  mHandler.destroy()
  super.onDestroy()
  }

  inner class ViewData/* (itemView: View) */ : RecyclerView.ViewHolder(itemView) {

  ViewData(this.itemView,);
  inner class RecyclerViewAdapter :
  RecyclerView.Adapter<ViewData>() {
  @override
  ViewData onCreateViewHolder(ViewGroup parent , int viewType )  {
  return ViewData(
  LayoutInflater.from(parent.context)
      .inflate(R.layout.page_imgview, parent, false)
  );
  }
  @override

  @SuppressLint("ClickableViewAccessibility", "SetTextI18n")
  void onBindViewHolder(ViewData holder , int position ) {
  final pos = if (r2l) realCount - position - 1 else position;
  final index2load = if(cut) (indexMap[pos]).abs() -1 else pos;
  final useCut = cut && isCut[index2load];
  final isLeft = cut && indexMap[pos] > 0;
  if (zipFile?.exists() == true) lifecycleScope.launch {
  getImgBitmap(index2load)?.let {
  //Glide.with(this@ViewMangaActivity).load(if(useCut) cutBitmap(it, isLeft) else it).into(holder.itemView.onei)
  holder.itemView.onei.setImageBitmap(if(useCut) cutBitmap(it, isLeft) else it)
  holder.itemView.oneb.visibility = View.GONE
  }
  }
  else getImgUrl(index2load)?.let{
  if(useCut) {
  final thisOneI = holder.itemView.onei;
  final thisOneB = holder.itemView.oneb;
  Glide.with(this@ViewMangaActivity.applicationContext)
      .asBitmap()
      .load(GlideUrl(CMApi.resolution.wrap(CMApi.imageProxy?.wrap(it)??it), CMApi.myGlideHeaders))
      .placeholder(BitmapDrawable(resources, getLoadingBitmap(pos)))
      .timeout(60000)
      .addListener(OneButtonRequestListener(thisOneB))
      .into(object : CustomTarget<Bitmap>() {
  @override
  static  void onResourceReady(Bitmap resource , Transition<in Bitmap>? transition ) {
  thisOneI.setImageBitmap(cutBitmap(resource, isLeft))
  }
  @override
  static  void onLoadCleared(Drawable? placeholder ) { }
  })
  } else Glide.with(this@ViewMangaActivity.applicationContext)
      .load(GlideUrl(CMApi.resolution.wrap(CMApi.imageProxy?.wrap(it)??it), CMApi.myGlideHeaders))
      .timeout(60000)
      .placeholder(BitmapDrawable(resources, getLoadingBitmap(pos)))
      .addListener(OneButtonRequestListener(holder.itemView.oneb))
      .into(holder.itemView.onei)
  }
  }
  @override

  int getItemCount()  {
  return realCount;
  }
  /* private */

  inner class OneButtonRequestListener<T>/* (/* private */ val thisOneB: Button) */ : RequestListener<T> {
  final Button thisOneB ;

  OneButtonRequestListener(this.thisOneB,);
  Target<T>? mTarget  = null;
  init {
  thisOneB.apply { post {
  setOnClickListener { mTarget?.request?.apply {
  clear();
  begin();
  } };
  }; }
  }
  @override
  bool onLoadFailed(
  GlideException? e ,
  Any? model ,
  Target<T> target ,
  bool isFirstResource
  )  {
  thisOneB.visibility = View.VISIBLE
  mTarget = target
  return false;
  }
  @override
  bool onResourceReady(
  T & Object resource ,
  Object model ,
  Target<T>? target ,
  DataSource dataSource ,
  bool isFirstResource
  )  {
  thisOneB.visibility = View.GONE
  return false;
  }
  }
  }
  }

  void showDrawer() {
  clicked = 2 // loading
  infseek.post {
  infseek.visibility = View.VISIBLE
  isearch.post {
  isearch.visibility = View.VISIBLE
  infseek.invalidate()
  isearch.invalidate()
  ObjectAnimator.ofFloat(
  oneinfo,
  "alpha",
  oneinfo.alpha,
  1
  ).setDuration(300).start()
  clicked = 1 // true
  }
  }
  }

  void hideDrawer() {
  clicked = 2 // loading
  ObjectAnimator.ofFloat(
  oneinfo,
  "alpha",
  oneinfo.alpha,
  0
  ).setDuration(300).start()
  infseek.postDelayed({
  infseek.visibility = View.GONE
  isearch.visibility = View.GONE
  infseek.invalidate()
  isearch.invalidate()
  clicked = 0 // false
  }, 300)
  mHandler.sendEmptyMessage(if (fullyHideInfo) VMHandler.HIDE_INFO_CARD_FULL else VMHandler.HIDE_INFO_CARD)
  }
  static Handler? dlHandler  = null;
  static WeakReference<ViewMangaActivity>? va  = null;
  static var noCellarAlert = false;


  companion object {



  }
}