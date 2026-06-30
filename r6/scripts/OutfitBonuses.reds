module OutfitBonuses

import EquipmentEx.OutfitSystem

public class OutfitBonusesSystem extends ScriptableSystem {
    private persistent let m_isFirstLoad: Bool = true;
    private persistent let m_activeBonuses: array<OutfitBonus>;
    private persistent let m_previousBonuses: array<OutfitBonus>;

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
        new OutfitBonus("CASUAL", gamedataStatType.StreetCredXPBonusMultiplier, 0.05, "+5% Street Cred earned"),
        new OutfitBonus("NIGHTCLUB", gamedataStatType.HealthOutOfCombatRegenRateMult, 0.3, "+30% Health Regen outside combat"),
        new OutfitBonus("SPORTSWEAR", gamedataStatType.ClimbSpeedModifier, 0.5, "+50% Climb Speed"),
        new OutfitBonus("PARKOUR", gamedataStatType.FallDamageReduction, 0.5, "+50% Fall Damage reduction"),
        new OutfitBonus("STEALTH", gamedataStatType.Visibility, -0.2, "-20% Visibility"),
        new OutfitBonus("SNIPER", gamedataStatType.HeadshotDamageMultiplier, 0.25, "+25% Headshot damage"),
        new OutfitBonus("ASSASSIN", gamedataStatType.AdditionalStealthDamage, 0.1, "+10% Stealth damage"),
        new OutfitBonus("PSYCHO", gamedataStatType.MeleeDamagePercentBonus, 0.1, "+10% Melee damage"),
        new OutfitBonus("ARMOURED", gamedataStatType.ExplosionResistance, 0.5, "+50% Explosion resistance"),
        new OutfitBonus("BODYGUARD", gamedataStatType.MeleeResistance, 0.2, "+20% Melee resistance"),
        new OutfitBonus("CYBER", gamedataStatType.MemoryRegenRate, 0.25, "+25% RAM regen rate"),
        new OutfitBonus("DRIVER", gamedataStatType.VehicleDamagePercentBonus, 0.5, "+50% Damage to vehicles"),
        new OutfitBonus("AUGMENTED", gamedataStatType.StrengthSkillcheckBonus, 3.0, "+3 to Strength skill checks"),
        new OutfitBonus("SOLDIER", gamedataStatType.ArmorPenetrationBonus, 0.1, "+10% Armour penetration"),
        new OutfitBonus("GEEK", gamedataStatType.TechnicalAbilitySkillcheckBonus, 3.0, "+3 to Technical Ability skill checks"),
        new OutfitBonus("HACKER", gamedataStatType.MinigameMoneyMultiplier, 0.5, "+50% Money rewards from hacking"),

        // Gang affiliations
        new OutfitBonus("6TH STREET", gamedataStatType.GrenadeDamagePercentBonus, 0.4, "+40% Grenade damage"),
        new OutfitBonus("ANIMAL", gamedataStatType.BerserkMeleeDamageBonus, 0.2, "+20% Damage during Beserk"),
        new OutfitBonus("BARGHEST", gamedataStatType.MitigationStrength, 0.1, "+10% Mitigation strength"),
        new OutfitBonus("MAELSTROM", gamedataStatType.CyberwareRechargeSpeedBonus, 0.2, "+20% Cyberware recharge speed"),
        new OutfitBonus("SCAVENGER", gamedataStatType.BonusPercentDamageToEnemiesBelowHalfHealth, 0.1, "+10% Damage to enemies below half health"),
        new OutfitBonus("MOX", gamedataStatType.DodgeStaminaCostReduction, 0.25, "+25% Dodge stamina reduction"),
        new OutfitBonus("TYGER", gamedataStatType.CritDamage, 0.2, "+20% Crit damage"), // or CritDamageBonus?
        new OutfitBonus("VALENTINO", gamedataStatType.ReloadSpeedPercentBonus, 0.2, "+20% Reload speed"),
        new OutfitBonus("VOODOO", gamedataStatType.DamageReductionQuickhacks, 0.3, "+30% Quickhack resistance"),

        // Corp affiliations
        new OutfitBonus("ARASAKA", gamedataStatType.MantisBladesStaminaCostReduction, 0.2, "+20% Mantis Blades stamina cost reduction"),
        new OutfitBonus("MILITECH", gamedataStatType.TechWeaponDamagePercentBonus, 0.15, "+15% Damage with Tech weapons"),
        new OutfitBonus("KANG TAO", gamedataStatType.SmartWeaponDamagePercentBonus, 0.15, "+15% Damage with Smart weapons"),
        new OutfitBonus("TSUNAMI", gamedataStatType.BonusRicochetDamage, 0.25, "+25% Ricochet chance with Power weapons"),
        new OutfitBonus("NETWATCH", gamedataStatType.CameraDetectionSpeedReduction, 0.4, "+40% Camera detection time"),
        
        // TTRPG roles
        new OutfitBonus("ROCKER", gamedataStatType.CritChance, 0.1, "+10% Crit chance"), // or CritChanceBonus?
        new OutfitBonus("SOLO", gamedataStatType.BonusPercentDamageToEnemiesAtFullHealth, 0.1, "+10% Damage to enemies at full health"),
        new OutfitBonus("NETRUNNER", gamedataStatType.BonusQuickHackDamage, 0.1, "+10% Quickhack damage"), // or QuickHackDamageBonusMultiplier?
        new OutfitBonus("TECHIE", gamedataStatType.DisassemblingIngredientsDoubleBonus, 0.5, "+50% Chance for bonus materials when disassembling"),
        new OutfitBonus("MEDTECH", gamedataStatType.HealingItemsEffectPercentBonus, 0.2, "+20% Health item effects"),
        new OutfitBonus("MEDIA", gamedataStatType.IntelligenceSkillcheckBonus, 3.0, "+3 to Intelligence skill checks"),
        new OutfitBonus("CORPO", gamedataStatType.VendorBuyPriceDiscount, 0.2, "Slightly better vendor prices"),
        new OutfitBonus("COP", gamedataStatType.ADSSpeedPercentBonus, 0.25, "+25% Aim Down Sight speed"),
        new OutfitBonus("FIXER", gamedataStatType.XPbonusMultiplier, 0.05, "+5% XP earned"),
        new OutfitBonus("NOMAD", gamedataStatType.CarryCapacity, 25.0, "+25 Carry capacity")
    ];
}

struct OutfitBonus {
    private let m_name: String;
    private let m_stat: gamedataStatType;
    private let m_additiveBonus: Float;
    private let m_desc: String;
}

@wrapMethod(gameuiInventoryGameController)
protected cb func OnWardrobeBtnClick(evt: ref<inkPointerEvent>) -> Bool {
    // LogChannel(n"DEBUG", "gameuiInventoryGameController::OnWardrobeBtnClick");

    // If preview button was clicked, show info popup instead
    if evt.IsAction(n"preview_item") {
        // Generate text for currently active outfit effects
        let activeBonuses = this.m_outfitBonusesSystem.m_activeBonuses;
        let appliedBonuses: String;
        let appliedEffects: String;
        let bonusCount = ArraySize(this.m_outfitBonusesSystem.m_activeBonuses);

        if bonusCount > 0 {
            appliedBonuses = "";
            appliedEffects = "(";
            let i = 0;
            while i < bonusCount {
                appliedBonuses += this.m_outfitBonusesSystem.m_activeBonuses[i].m_name;
                appliedEffects += this.m_outfitBonusesSystem.m_activeBonuses[i].m_desc;
                if i < bonusCount - 1 {
                    appliedBonuses += ", ";
                    appliedEffects += ", ";
                } else {
                    appliedEffects += ")\n\n";
                }
                i += 1;
            }
        } else {
            appliedBonuses = "None";
            appliedEffects = "";
        }

        this.m_wardrobePopup = GenericMessageNotification.Show(
            this, 
            "Active Bonuses: " + appliedBonuses, 
            appliedEffects +
            "The following outfit names apply bonus effects:\n\n" +
            "Generic keywords:\n" + 
            "- CASUAL, NIGHTCLUB, SPORTSWEAR, PARKOUR, STEALTH, SNIPER, ASSASSIN, PSYCHO, ARMOURED, BODYGUARD, CYBER, DRIVER, AUGMENTED, SOLDIER, GEEK, HACKER\n\n" +
            "Gang affiliations:\n" +
            "- 6TH STREET, ANIMAL, BARGHEST, MAELSTROM, SCAVENGER, MOX, TYGER, VALENTINO, VOODOO\n\n" +
            "Corp affiliations:\n" +
            "- ARASAKA, MILITECH, KANG TAO, TSUNAMI, NETWATCH\n\n" +
            "Roles:\n" +
            "- ROCKER, SOLO, NETRUNNER, TECHIE, MEDTECH, MEDIA, CORPO, COP, FIXER, NOMAD", 
            GenericMessageNotificationType.OK
        );
        this.m_wardrobePopup.RegisterListener(this, n"OnWardrobePopupClose");
        return false;
    } else {
        return wrappedMethod(evt);
    }
}

@addMethod(gameuiInventoryGameController)
protected cb func OnWardrobeBtnHoverOver(evt: ref<inkPointerEvent>) {
    // LogChannel(n"DEBUG", "gameuiInventoryGameController::OnWardrobeBtnHoverOver");

    // this.m_buttonHintsController.Show();
    this.m_buttonHintsController.AddButtonHint(n"preview_item", "Outfit Bonuses");
}

@addMethod(gameuiInventoryGameController)
protected cb func OnWardrobeBtnHoverOut(evt: ref<inkPointerEvent>) {
    // LogChannel(n"DEBUG", "gameuiInventoryGameController::OnWardrobeBtnHoverOut");

    // this.m_buttonHintsController.Hide();
    this.m_buttonHintsController.RemoveButtonHint(n"preview_item");
}

@addField(gameuiInventoryGameController)
private let m_outfitBonusesSystem: wref<OutfitBonusesSystem>;

@wrapMethod(gameuiInventoryGameController)
protected cb func OnInitialize() -> Bool {
    // LogChannel(n"DEBUG", "gameuiInventoryGameController::OnInitialize");
    wrappedMethod();

    let game = this.m_player.GetGame();
    this.m_outfitBonusesSystem = OutfitBonusesSystem.GetInstance(game);

    // Preview button callbacks
    this.m_wardrobeButton.RegisterToCallback(n"OnHoverOver", this, n"OnWardrobeBtnHoverOver");
    this.m_wardrobeButton.RegisterToCallback(n"OnHoverOut", this, n"OnWardrobeBtnHoverOut");
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

        // Save it to previous outfit before clearing, so we can diff it later
        this.m_outfitBonusesSystem.m_previousBonuses = this.m_outfitBonusesSystem.m_activeBonuses;
        ArrayClear(this.m_outfitBonusesSystem.m_activeBonuses);
    }

    // Apply new outfit bonuses
    for bonus in OutfitBonusesSystem.OutfitBonusDefinitions() {
        if StrContains(StrUpper(s"\(currentOutfit)"), bonus.m_name) {
            // LogChannel(n"DEBUG", s"ApplyBonus -> \(bonus.m_name)");

            ArrayPush(this.m_outfitBonusesSystem.m_activeBonuses, bonus);

            // let currentStatValue = GameInstance.GetStatsSystem(game).GetStatValue(Cast<StatsObjectID>(this.m_player.GetEntityID()), stat);
            let statMod = RPGManager.CreateStatModifier(bonus.m_stat, gameStatModifierType.Additive, bonus.m_additiveBonus) as gameConstantStatModifierData;
            statsSystem.AddModifier(Cast<StatsObjectID>(this.m_player.GetEntityID()), statMod);
        }
    }
    
    // Display message
    // (only if bonuses have changed since last outfit)
    let bonusCount = ArraySize(this.m_outfitBonusesSystem.m_activeBonuses);
    if Equals(bonusCount, ArraySize(this.m_outfitBonusesSystem.m_previousBonuses)) {
        let changedCount = 0;
        for bonus in this.m_outfitBonusesSystem.m_activeBonuses {
            if !ArrayContains(this.m_outfitBonusesSystem.m_previousBonuses, bonus) {
                changedCount += 1;
            }
        }
        if Equals(changedCount, 0) {
            return wrappedMethod();
        }
    }

    if bonusCount > 0 {
        let appliedBonuses = "";
        let i = 0;
        while i < bonusCount {
            appliedBonuses += this.m_outfitBonusesSystem.m_activeBonuses[i].m_name;
            if i < bonusCount - 1 {
                appliedBonuses += ", ";
            }
            i += 1;
        }
        InfoMessage(game, s"Outfit Bonus\(bonusCount > 1 ? "es" : "") applied: \(appliedBonuses)");
    }
    
    return wrappedMethod();
}

private static func ResetPreviousStatMods(activeBonuses: array<OutfitBonus>, statsSystem: ref<StatsSystem>, player: wref<PlayerPuppet>) {
    for bonus in activeBonuses {
        // LogChannel(n"DEBUG", s"ResetBonus -> \(bonus.m_name)");
        
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
