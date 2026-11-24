struct MeterPanel: View {
    @Bindable var viewModel: MeterViewModel
    let readout: MeterReadout

    var body: some View {
        GlassPanel {
            VStack(spacing: Spacing.s12) {
                Picker(...)
                if viewModel.mode == .auto { EquivalentsRow(...) }
                HStack(spacing: Spacing.s8) { ... }
                HStack { ... }
                PrimaryActionButton(...)
            }
        }
    }
}