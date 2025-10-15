package dev.tutushkin.allmovies.presentation.movies.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.View.generateViewId
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.material.chip.Chip
import dev.tutushkin.allmovies.databinding.BottomSheetFiltersBinding
import dev.tutushkin.allmovies.domain.movies.models.SearchFilters
import dev.tutushkin.allmovies.domain.movies.models.TriState
import dev.tutushkin.allmovies.presentation.movies.viewmodel.SearchUiState

class SearchFilterBottomSheet : BottomSheetDialogFragment() {

    private var _binding: BottomSheetFiltersBinding? = null
    private val binding get() = _binding!!

    var state: SearchUiState = SearchUiState()
    var onApply: ((SearchFilters) -> Unit)? = null

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = BottomSheetFiltersBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        populateGenres()
        populateFormats()
        populateAges()
        configureTypeToggles()
        configureTriStateToggle(binding.seenToggleGroup, state.filters.seen)
        configureTriStateToggle(binding.ownedToggleGroup, state.filters.owned)
        configureTriStateToggle(binding.favouriteToggleGroup, state.filters.favourite)

        binding.applyButton.setOnClickListener {
            onApply?.invoke(collectFilters())
            dismiss()
        }

        binding.resetButton.setOnClickListener {
            onApply?.invoke(SearchFilters(query = state.query))
            dismiss()
        }
    }

    private fun populateGenres() {
        binding.genresChipGroup.removeAllViews()
        state.availableGenres.forEach { (id, name) ->
            val chip = createChip(name).apply {
                tag = id
                isChecked = state.filters.categories.contains(id)
            }
            binding.genresChipGroup.addView(chip)
        }
    }

    private fun populateFormats() {
        binding.formatChipGroup.removeAllViews()
        state.availableFormats.forEach { format ->
            val chip = createChip(format).apply {
                tag = format
                isChecked = state.filters.formats.contains(format)
            }
            binding.formatChipGroup.addView(chip)
        }
    }

    private fun populateAges() {
        binding.ageChipGroup.removeAllViews()
        state.availableAgeRatings.forEach { rating ->
            val chip = createChip(rating).apply {
                tag = rating
                isChecked = state.filters.ageRatings.contains(rating)
            }
            binding.ageChipGroup.addView(chip)
        }
    }

    private fun configureTypeToggles() {
        binding.typeMovies.isChecked = state.filters.includeMovies
        binding.typeTv.isChecked = state.filters.includeTv
        if (!state.filters.includeMovies && !state.filters.includeTv) {
            binding.typeMovies.isChecked = true
            binding.typeTv.isChecked = true
        }
    }

    private fun configureTriStateToggle(toggleGroup: com.google.android.material.button.MaterialButtonToggleGroup, state: TriState) {
        if (toggleGroup.childCount < 3) return
        when (state) {
            TriState.ANY -> toggleGroup.check(toggleGroup.getChildAt(0).id)
            TriState.ENABLED -> toggleGroup.check(toggleGroup.getChildAt(1).id)
            TriState.DISABLED -> toggleGroup.check(toggleGroup.getChildAt(2).id)
        }
    }

    private fun collectFilters(): SearchFilters {
        val selectedGenres = binding.genresChipGroup.checkedChipIds.mapNotNull { id ->
            binding.genresChipGroup.findViewById<Chip>(id)?.tag as? Int
        }.toSet()

        val formats = binding.formatChipGroup.checkedChipIds.mapNotNull { id ->
            binding.formatChipGroup.findViewById<Chip>(id)?.tag as? String
        }.toSet()

        val ages = binding.ageChipGroup.checkedChipIds.mapNotNull { id ->
            binding.ageChipGroup.findViewById<Chip>(id)?.tag as? String
        }.toSet()

        val includeMovies = binding.typeMovies.isChecked
        val includeTv = binding.typeTv.isChecked

        return state.filters.copy(
            categories = selectedGenres,
            formats = formats,
            ageRatings = ages,
            includeMovies = includeMovies || (!includeMovies && !includeTv),
            includeTv = includeTv || (!includeMovies && !includeTv),
            seen = resolveTriState(binding.seenToggleGroup),
            owned = resolveTriState(binding.ownedToggleGroup),
            favourite = resolveTriState(binding.favouriteToggleGroup)
        )
    }

    private fun resolveTriState(toggleGroup: com.google.android.material.button.MaterialButtonToggleGroup): TriState {
        if (toggleGroup.childCount < 3) return TriState.ANY
        return when (toggleGroup.checkedButtonId) {
            toggleGroup.getChildAt(1).id -> TriState.ENABLED
            toggleGroup.getChildAt(2).id -> TriState.DISABLED
            else -> TriState.ANY
        }
    }

    private fun createChip(text: String): Chip = Chip(requireContext()).apply {
        id = generateViewId()
        this.text = text
        isCheckable = true
        isClickable = true
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
