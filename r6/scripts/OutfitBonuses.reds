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
        // Generic outfit types
        new OutfitBonus("CASUAL", gamedataStatType.StreetCredXPBonusMultiplier, 0.05),
        new OutfitBonus("NIGHTCLUB", gamedataStatType.VendorBuyPriceDiscount, 0.2),
        new OutfitBonus("SPORTY", gamedataStatType.StaminaRegenRate, 0.2),
        new OutfitBonus("STEALTH", gamedataStatType.Visibility, -0.2),
        new OutfitBonus("SNIPER", gamedataStatType.HeadshotDamageMultiplier, 0.25),
        new OutfitBonus("ASSASSIN", gamedataStatType.AdditionalStealthDamage, 0.2),
        new OutfitBonus("PSYCHO", gamedataStatType.MeleeDamagePercentBonus, 0.15),
        new OutfitBonus("ARMOURED", gamedataStatType.ExplosionResistance, 0.5),
        new OutfitBonus("BODYGUARD", gamedataStatType.MeleeResistance, 0.3),
        new OutfitBonus("CYBER", gamedataStatType.MemoryRegenRate, 0.25),
        new OutfitBonus("HACKER", gamedataStatType.MinigameMoneyMultiplier, 0.5),
        new OutfitBonus("DRIVER", gamedataStatType.VehicleDamagePercentBonus, 0.5),
        new OutfitBonus("AUGMENTED", gamedataStatType.StrengthSkillcheckBonus, 3.0),
        new OutfitBonus("GEEK", gamedataStatType.TechnicalAbilitySkillcheckBonus, 3.0),

        // Gang affiliations
        new OutfitBonus("6TH STREET", gamedataStatType.GrenadeDamagePercentBonus, 0.4),
        new OutfitBonus("ANIMAL", gamedataStatType.BerserkMeleeDamageBonus, 0.2),
        new OutfitBonus("BARGHEST", gamedataStatType.MitigationStrength, 0.2),
        new OutfitBonus("MAELSTROM", gamedataStatType.CyberwareRechargeSpeedBonus, 0.2),
        new OutfitBonus("SCAVENGER", gamedataStatType.BonusPercentDamageToEnemiesBelowHalfHealth, 0.1),
        new OutfitBonus("MOX", gamedataStatType.DodgeStaminaCostReduction, 0.25), 
        new OutfitBonus("TYGER", gamedataStatType.CritDamage, 0.25), // or CritDamageBonus?
        new OutfitBonus("VALENTINO", gamedataStatType.ReloadSpeedPercentBonus, 0.1),
        new OutfitBonus("VOODOO", gamedataStatType.DamageReductionQuickhacks, 0.3),

        // TTRPG roles
        new OutfitBonus("ROCKER", gamedataStatType.CritChance, 0.1), // or CritChanceBonus?
        new OutfitBonus("SOLO", gamedataStatType.BonusPercentDamageToEnemiesAtFullHealth, 0.1),
        new OutfitBonus("NETRUNNER", gamedataStatType.BonusQuickHackDamage, 0.1), // or QuickHackDamageBonusMultiplier?
        new OutfitBonus("TECHIE", gamedataStatType.DisassemblingIngredientsDoubleBonus, 0.5),
        new OutfitBonus("MEDTECH", gamedataStatType.HealingItemsEffectPercentBonus, 0.2),
        new OutfitBonus("MEDIA", gamedataStatType.IntelligenceSkillcheckBonus, 3.0),
        new OutfitBonus("CORPO", gamedataStatType.VendorSellPriceDiscount, 0.2),
        new OutfitBonus("COP", gamedataStatType.ADSSpeedPercentBonus, 0.2),
        new OutfitBonus("FIXER", gamedataStatType.XPbonusMultiplier, 0.05),
        new OutfitBonus("NOMAD", gamedataStatType.CarryCapacity, 0.1)
    ];
}

struct OutfitBonus {
    private let m_name: String;
    private let m_stat: gamedataStatType;
    private let m_additiveBonus: Float;
}

@addField(gameuiInventoryGameController)
private let m_outfitBonusesSystem: wref<OutfitBonusesSystem>;

@wrapMethod(gameuiInventoryGameController)
protected cb func OnInitialize() -> Bool {
    // LogChannel(n"DEBUG", "gameuiInventoryGameController::OnInitialize");
    wrappedMethod();

    let game = this.m_player.GetGame();
    this.m_outfitBonusesSystem = OutfitBonusesSystem.GetInstance(game);
}

@wrapMethod(gameuiInventoryGameController)
protected cb func OnUninitialize() -> Bool {
    // LogChannel(n"DEBUG", "gameuiInventoryGameController::OnUninitialize");

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
            let statMod = RPGManager.CreateStatModifier(bonus.m_stat, gameStatModifierType.Additive, bonus.m_additiveBonus) as gameConstantStatModifierData;
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
        let statMod = RPGManager.CreateStatModifier(bonus.m_stat, gameStatModifierType.Additive, -bonus.m_additiveBonus) as gameConstantStatModifierData;
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
