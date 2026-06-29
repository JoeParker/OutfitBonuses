module OutfitBonuses

import EquipmentEx.OutfitSystem

public class OutfitBonusesSystem extends ScriptableSystem {
    private persistent let m_isFirstLoad: Bool = true;
    private persistent let m_activeBonuses: array<OutfitBonus>;

    private func OnAttach() -> Void {
        // LogChannel(n"DEBUG", "OutfitBonusesSystem::OnAttach");
    }

    private func OnDetach() -> Void {
        // LogChannel(n"DEBUG", "OutfitBonusesSystem::OnDetach");
    }

    public static func GetInstance(game: GameInstance) -> ref<OutfitBonusesSystem> {
        return GameInstance.GetScriptableSystemsContainer(game).Get(n"OutfitBonuses.OutfitBonusesSystem") as OutfitBonusesSystem;
    }

    public static func OutfitBonusDefinitions() -> array<OutfitBonus> = [
        new OutfitBonus("CORPO", gamedataStatType.VendorBuyPriceDiscount, 1.2),
        new OutfitBonus("STEALTH", gamedataStatType.Visibility, 0.8),
        new OutfitBonus("CO", gamedataStatType.VendorSellPriceDiscount, 1.2)
    ];
}

struct OutfitBonus {
    private let m_name: String;
    private let m_stat: gamedataStatType;
    private let m_multiplier: Float;
}

@addField(gameuiInventoryGameController)
private let m_outfitBonusesSystem: wref<OutfitBonusesSystem>;

@wrapMethod(gameuiInventoryGameController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();

    let game = this.m_player.GetGame();
    this.m_outfitBonusesSystem = OutfitBonusesSystem.GetInstance(game);

    LogChannel(n"DEBUG", "gameuiInventoryGameController::OnInitialize");
}

@wrapMethod(gameuiInventoryGameController)
protected cb func OnUninitialize() -> Bool {
    LogChannel(n"DEBUG", "gameuiInventoryGameController::OnUninitialize");

    let game = this.m_player.GetGame();
    let outfitSystem = OutfitSystem.GetInstance(game);
    let outfits = outfitSystem.GetOutfits();
    
    // Get current outfit
    let currentOutfit: CName;
    for outfit in outfits {
        if outfitSystem.IsEquipped(outfit) {
            currentOutfit = outfit;
        }
    }

    let statsSystem = GameInstance.GetStatsSystem(game);

    // Clear previous outfit bonuses
    if this.m_outfitBonusesSystem.m_isFirstLoad {
        // LogChannel(n"DEBUG", s"OutfitBonuses -> First load");
        this.m_outfitBonusesSystem.m_isFirstLoad = false;
    } else {
        // LogChannel(n"DEBUG", s"OutfitBonuses -> Not First load");
        ResetPreviousStatMods(this.m_outfitBonusesSystem.m_activeBonuses, statsSystem, this.m_player);
        ArrayClear(this.m_outfitBonusesSystem.m_activeBonuses);
    }

    // Apply new outfit bonuses
    for bonus in OutfitBonusesSystem.OutfitBonusDefinitions() {
        if StrContains(StrUpper(s"\(currentOutfit)"), bonus.m_name) {
            LogChannel(n"DEBUG", s"ApplyBonus -> \(bonus.m_name)");

            ArrayPush(this.m_outfitBonusesSystem.m_activeBonuses, bonus);

            // let currentStatValue = GameInstance.GetStatsSystem(game).GetStatValue(Cast<StatsObjectID>(this.m_player.GetEntityID()), stat);
            let statMod = RPGManager.CreateStatModifier(bonus.m_stat, gameStatModifierType.Multiplier, bonus.m_multiplier) as gameConstantStatModifierData;
            statsSystem.AddModifier(Cast<StatsObjectID>(this.m_player.GetEntityID()), statMod);
        }
    }
    // Message
    let bonusCount = ArraySize(this.m_outfitBonusesSystem.m_activeBonuses);
    if bonusCount > 0 {
        let appliedBonuses = "";
        let i = 0;
        while i < bonusCount {
            appliedBonuses += this.m_outfitBonusesSystem.m_activeBonuses[i].m_name;
            if i < bonusCount - 1 {
                appliedBonuses += " + ";
            }
            i += 1;
        }
        InfoMessage(game, s"\(appliedBonuses) outfit bonus\(bonusCount > 1 ? "es" : "") activated");
    }
    
    return wrappedMethod();
}

private static func ResetPreviousStatMods(activeBonuses: array<OutfitBonus>, statsSystem: ref<StatsSystem>, player: wref<PlayerPuppet>) {
    for bonus in activeBonuses {
        LogChannel(n"DEBUG", s"ResetBonus -> \(bonus.m_name)");
        // let currentStatValue = GameInstance.GetStatsSystem(game).GetStatValue(Cast<StatsObjectID>(this.m_player.GetEntityID()), stat);
        let statMod = RPGManager.CreateStatModifier(bonus.m_stat, gameStatModifierType.Multiplier, 1.0 / bonus.m_multiplier) as gameConstantStatModifierData;
        statsSystem.AddModifier(Cast<StatsObjectID>(player.GetEntityID()), statMod);
    }
}

private static func InfoMessage(game: GameInstance, msg: String) -> Void {
    let onscreenMsg: SimpleScreenMessage;
    onscreenMsg.duration = 2.0;
    onscreenMsg.isShown = true;		
    onscreenMsg.message = msg;
    onscreenMsg.type = SimpleMessageType.Neutral;

    GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(onscreenMsg), true);
}
