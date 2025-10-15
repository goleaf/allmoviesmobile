package dev.tutushkin.allmovies.presentation.imdb.view.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import dev.tutushkin.allmovies.databinding.ViewHolderImdbSearchResultBinding
import dev.tutushkin.allmovies.domain.movies.models.ImdbSearchResult

class ImdbSearchAdapter(
    private val listener: ImdbSearchClickListener
) : ListAdapter<ImdbSearchResult, ImdbSearchViewHolder>(ImdbSearchDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ImdbSearchViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        val binding = ViewHolderImdbSearchResultBinding.inflate(inflater, parent, false)
        return ImdbSearchViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ImdbSearchViewHolder, position: Int) {
        holder.bind(getItem(position), listener)
    }
}

class ImdbSearchViewHolder(
    private val binding: ViewHolderImdbSearchResultBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(result: ImdbSearchResult, listener: ImdbSearchClickListener) {
        binding.imdbResultTitle.text = result.title
        binding.imdbResultYear.text = result.year
        Glide.with(binding.root.context)
            .load(result.poster)
            .into(binding.imdbResultPoster)

        binding.root.setOnClickListener {
            listener.onImdbSearchResultClick(result)
        }
    }
}

class ImdbSearchDiffCallback : DiffUtil.ItemCallback<ImdbSearchResult>() {
    override fun areItemsTheSame(oldItem: ImdbSearchResult, newItem: ImdbSearchResult): Boolean {
        return oldItem.imdbId == newItem.imdbId
    }

    override fun areContentsTheSame(oldItem: ImdbSearchResult, newItem: ImdbSearchResult): Boolean {
        return oldItem == newItem
    }
}

interface ImdbSearchClickListener {
    fun onImdbSearchResultClick(result: ImdbSearchResult)
}
