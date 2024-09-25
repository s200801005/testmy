// This is a translation from Kotlin to Dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_project_name/api/cm_api.dart'; // Example import
import 'package:your_project_name/models/book_list_structure.dart'; // Example import
import 'package:your_project_name/utils/glide_hide_lottie_view_listener.dart'; // Example import
import 'package:your_project_name/widgets/no_back_refresh_fragment.dart'; // Example import

/*package top.fumiama.copymanga.ui.home
import android.annotation.SuppressLint
import android.app.AlertDialog
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ImageButton
import android.widget.Toast
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.model.GlideUrl
import com.google.gson.Gson
import com.lapism.search.internal.SearchLayout
import kotlinx.android.synthetic.main.card_book_plain.view.*
import kotlinx.android.synthetic.main.fragment_home.*
import kotlinx.android.synthetic.main.line_word.view.*
import kotlinx.android.synthetic.main.viewpage_horizonal.view.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import top.fumiama.copymanga.MainActivity
import top.fumiama.copymanga.MainActivity.Companion.ime
import top.fumiama.copymanga.json.BookListStructure
import top.fumiama.copymanga.template.general.NoBackRefreshFragment
import top.fumiama.copymanga.template.http.PausableDownloader
import top.fumiama.copymanga.tools.api.CMApi
import top.fumiama.copymanga.tools.ui.GlideHideLottieViewListener
import top.fumiama.copymanga.tools.ui.Navigate
import top.fumiama.dmzj.copymanga.R
import java.lang.ref.WeakReference
*/

class HomeFragment : NoBackRefreshFragment(R.layout.fragment_home) {
    lateinit HomeHandler; homeHandler 
     @override

    @SuppressLint("ClickableViewAccessibility")
     void onViewCreated(View view , Bundle? savedInstanceState ) {
        super.onViewCreated(view, savedInstanceState)
        if(isFirstInflate) {
            final tb = (activity as MainActivity).toolsBox;
            final netInfo = tb.netInfo;
            if(netInfo != tb.transportStringNull && netInfo != tb.transportStringError)
                MainActivity.member?.apply { lifecycleScope.launch {
                    info().let { l ->
                        if (l.code != 200 && l.code != 449) {
                            Toast.makeText(context, l.message, Toast.LENGTH_SHORT).show()
                            logout();
                        }
                    }
                } }
            homeHandler = HomeHandler(WeakReference(this))

            final theme = resources.newTheme();
            swiperefresh?.setColorSchemeColors(
                resources.getColor(R.color.colorAccent, theme),
                resources.getColor(R.color.colorBlue2, theme),
                resources.getColor(R.color.colorGreen, theme))
            swiperefresh?.isEnabled = true

            fhl?.setPadding(0, 0, 0, navBarHeight)

            fhs?.apply {
                isNestedScrollingEnabled = true
                final recyclerView = findViewById<RecyclerView>(R.id.search_recycler_view);
                recyclerView.isNestedScrollingEnabled = true
                recyclerView.setPadding(0, 0, 0, navBarHeight)
                setAdapterLayoutManager(LinearLayoutManager(context));
                final adapter = ListViewHolder(recyclerView).RecyclerViewAdapter();
                setAdapter(adapter);
                navigationIconSupport = SearchLayout.NavigationIconSupport.SEARCH
                setMicIconImageResource(R.drawable.ic_setting_search);
                final micView = findViewById<ImageButton>(R.id.search_image_view_mic);
                setClearFocusOnBackPressed(true);
                setOnNavigationClickListener(object : SearchLayout.OnNavigationClickListener {
                     @override
                    static  void onNavigationClick(bool hasFocus ) {
                        if (hasFocus()) {
                            clearFocus();
                        }
                        else requestFocus()
                    }
                });
                setTextHint(android.R.string.search_go);

                var lastSearch = "";
                setOnQueryTextListener(object : SearchLayout.OnQueryTextListener {
                    static var lastChangeTime = 0;
                     @override
                    static  bool onQueryTextChange(CharSequence newText )  {
                        if (newText.contentEquals("__notice_focus_change__") || newText.contentEquals(lastSearch)) return true;
                        postDelayed({
                            lifecycleScope.launch {
                                final diff = System.currentTimeMillis() - lastChangeTime;
                                if(diff > 500) {
                                    if (newText.isNotEmpty) {
                                        Log.d("MyHF", "new text: $newText")
                                        lastSearch = newText.toString()
                                        adapter.refresh(newText)
                                    }
                                }
                            }
                        }, 1024);
                        lastChangeTime = System.currentTimeMillis()
                        return true;
                    }
                     @override

                    static  bool onQueryTextSubmit(CharSequence query )  {
                        /*if(query.isNotEmpty()) {
                            val key = query.toString()
                            Toast.makeText(context, key, Toast.LENGTH_SHORT).show()
                        }*/
                        Log.d("MyHF", "recover text: $lastSearch")
                        setTextQuery(lastSearch, false);
                        return true;
                    }
                });

                setOnMicClickListener(object : SearchLayout.OnMicClickListener {
                    static final types = arrayOf("", "name", "author", "local");
                    static var i = 0;
                     @override
                    static  void onMicClick() {
                        final typeNames = resources.getStringArray(R.array.search_types);
                        AlertDialog.Builder(context)
                            .setTitle(R.string.set_search_types)
                            .setIcon(R.mipmap.ic_launcher)
                            .setSingleChoiceItems(ArrayAdapter(context, R.layout.line_choice_list, typeNames), i){ d, p ->
                                adapter.type = types[p]
                                i = p
                                d.cancel()
                            }.show()
                    }
                });

                var isInFocusWaiting = false;
                setOnFocusChangeListener(object : SearchLayout.OnFocusChangeListener {
                     @override
                    static  void onFocusChange(bool hasFocus ) {
                        Log.d("MyHF", "fhs onFocusChange: $hasFocus")
                        if (isInFocusWaiting) return;
                        isInFocusWaiting = true
                        postDelayed({
                            navigationIconSupport = if (hasFocus) {
                                setTextQuery("__notice_focus_change__", true);
                                SearchLayout.NavigationIconSupport.ARROW
                            }
                            else {
                                if (lastSearch.isNotEmpty) {
                                    micView?.visibility = View.VISIBLE
                                }
                                SearchLayout.NavigationIconSupport.SEARCH
                            }
                            isInFocusWaiting = false
                        }, 300);
                    }
                });

                setOnTouchListener { _, e ->
                    Log.d("MyHF", "fhns on touch")
                    if (e.action == MotionEvent.ACTION_UP && mSearchEditText?.text?.isNotEmpty == true) {
                        ime?.hideSoftInputFromWindow(activity?.window?.decorView?.windowToken, 0)
                    }
                    false
                };
            }

            lifecycleScope.launch{
                withContext(Dispatchers.IO) {
                    homeHandler.obtainMessage(-1, true).sendToTarget()
                    while(!MainActivity.isDrawerClosed) delay(233)
                    //homeHandler.sendEmptyMessage(6)    //removeAllViews
                    //homeHandler.fhib = null
                    delay(300);
                    homeHandler.startLoad()
                };
            }
        }
    }
     @override

     void onResume() {
        super.onResume()
        swiperefresh?.isRefreshing = false
    }
     @override

     void onDestroy() {
        super.onDestroy()
        homeHandler.destroy()
    }

    inner class ViewData/* (itemView: View) */ : RecyclerView.ViewHolder(itemView) {
        
ViewData(this.itemView,);
inner class RecyclerViewAdapter :
            RecyclerView.Adapter<ViewData>() {
             @override
             ViewData onCreateViewHolder(ViewGroup parent , int viewType )  {
                return ViewData(layoutInflater.inflate(R.layout.viewpage_horizonal, parent, false));
            }
             @override

             void onBindViewHolder(ViewData holder , int position ) {
                final thisBanner = homeHandler.index?.results?.banners?.get(position);
                thisBanner?.cover?.let {
                    if(it.isEmpty) return@let;
                    //Log.d("MyHomeFVP", "Load img: $it")
                    Glide.with(this@HomeFragment).load(
                        GlideUrl(CMApi.imageProxy?.wrap(it)??it, CMApi.myGlideHeaders)
                    )
                        .addListener(GlideHideLottieViewListener(WeakReference(holder.itemView.lai)))
                        .timeout(60000).into(holder.itemView.vpi)
                }
                holder.itemView.vpt.text = thisBanner?.brief
                holder.itemView.vpc.setOnClickListener {
                    final bundle = Bundle();
                    homeHandler.index?.results?.banners?.get(position)?.comic?.path_word?.let { it1 -> bundle.putString("path", it1) }
                    Navigate.safeNavigateTo(findNavController(), R.id.action_nav_home_to_nav_book, bundle)
                }
            }
             @override

             int getItemCount()  => homeHandler.index?.results?.banners?.size??0
        }
    }

    inner class ListViewHolder/* (itemView: View) */ : RecyclerView.ViewHolder(itemView) {
        
ListViewHolder(this.itemView,);
inner class RecyclerViewAdapter :
            RecyclerView.Adapter<ListViewHolder>() {
             /* private */
             BookListStructure? results  = null;
            var type = "";
             /* private */
             String? query  = null;
             /* private */
             var count = 0;
             @override
             ListViewHolder onCreateViewHolder(ViewGroup parent , int viewType )  {
                return ListViewHolder(
                    LayoutInflater.from(parent.context)
                        .inflate(R.layout.line_word, parent, false)
                );
            }
             @override

            @SuppressLint("ClickableViewAccessibility", "SetTextI18n")
             void onBindViewHolder(ListViewHolder holder , int position ) {
                Log.d("MyMain", "Bind open at $position")
                if (position == itemCount-1) {
                    holder.itemView.apply { post {
                        tn.setText(R.string.button_more)
                        ta.text = "搜索 \"$query\""
                        tb.text = "共 $count 条结果"
                        context?.let {
                            Glide.with(it).load(R.drawable.img_defmask)
                                .addListener(GlideHideLottieViewListener(WeakReference(laic)))
                                .timeout(60000)
                                .into(imic)
                        }
                        cic.isClickable = false
                        lwc.setOnClickListener {
                            if (query?.isNotEmpty != true) return@setOnClickListener;
                            final bundle = Bundle();
                            bundle.putCharSequence("query", query)
                            bundle.putString("type", type)
                            Navigate.safeNavigateTo(findNavController(), R.id.action_nav_home_to_nav_search, bundle)
                        }
                        lwc.layoutParams.height = fhs.width / 4
                    }; }
                    return;
                }
                results?.results?.list?.get(position)?.apply {
                    holder.itemView.apply { post {
                        lwi.visibility = View.VISIBLE
                        tn.text = name
                        ta.text = author.let {
                            var t = "";
                            it.forEach { ts ->
                                t += ts.name + " "
                            }
                            return@let t;
                        }
                        tb.text = popular.toString()
                        cic.isClickable = false
                        context?.let {
                            Glide.with(it)
                                .load(GlideUrl(CMApi.imageProxy?.wrap(cover)??cover, CMApi.myGlideHeaders))
                                .addListener(GlideHideLottieViewListener(WeakReference(laic)))
                                .timeout(60000).into(imic)
                        }
                        lwc.setOnClickListener {
                            final bundle = Bundle();
                            bundle.putString("path", path_word)
                            Navigate.safeNavigateTo(findNavController(), R.id.action_nav_home_to_nav_book, bundle)
                        }
                        lwc.layoutParams.height = fhs.width / 4
                    }; }
                }
            }
             @override

             fun getItemCount() => (results?.results?.list?.size??0) + if (query?.isNotEmpty == true) 1 else 0

            /* suspend */ Future<Object>  refresh(CharSequence q ) => withContext(Dispatchers.IO) {
                query = q.toString()
                activity?.apply {
                    PausableDownloader(getString(R.string.searchApiUrl).format(CMApi.myHostApiUrl, 0, query, type)) {
                        results = Gson().fromJson(it.decodeToString(), BookListStructure::class.java)
                        count = results?.results?.total??0
                        withContext(Dispatchers.Main) {
                            notifyDataSetChanged();
                        };
                    }.run()
                }
            }
        }
    }
}