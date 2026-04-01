# Integration Roadmap: vimic/vimic2 → NORAD War Simulator

## Overview

This document outlines how concepts from vimic (VM provisioning tool) and vimic2 (orchestration platform) can be integrated into NORAD War Simulator to enhance gameplay mechanics.

**Note:** vimic/vimic2 are VM management tools, not weapons systems. This roadmap translates their architectural concepts into game mechanics.

---

## Concept Translation

### vimic/vimic2 Concepts → Game Mechanics

| vimic Concept | NORAD Game Equivalent |
|---------------|----------------------|
| Hypervisor (Node creation) | Defense Site Deployment |
| NodeConfig (VM specs) | Interceptor Battery Configuration |
| NodeState (Running/Stopped) | Site Status (Active/Inactive/Destroyed) |
| AutoScaler (Auto-scaling) | Auto-intercept Doctrine |
| Cluster Manager | Regional Defense Network |
| Metrics (CPU/Memory) | Site Readiness (Interceptors/Personnel) |
| Orchestrator | DEFCON Response Automation |
| Cicerone AI Client | Command Center AI Assistant |

---

## Integration Phases

### Phase 1: Defense Site Infrastructure (Weeks 1-2)

**Goal:** Use vimic's hypervisor pattern for defense site management.

#### From vimic:
```go
// Hypervisor interface
type Hypervisor interface {
    CreateNode(ctx context.Context, cfg *NodeConfig) (*Node, error)
    DeleteNode(ctx context.Context, id string) error
    StartNode(ctx context.Context, id string) error
    StopNode(ctx context.Context, id string) error
    ListNodes(ctx context.Context) ([]*Node, error)
    GetNodeStatus(ctx context.Context, id string) (*NodeStatus, error)
}
```

#### To NORAD:
```gdscript
# DefenseSiteManager - inspired by vimic hypervisor
class_name DefenseSiteManager

# Site configuration (like NodeConfig)
var SITE_CONFIGS := {
    "GBI_Fort_Greely": {
        "interceptor_type": "GBI",
        "capacity": 40,
        "response_time": 120,  # seconds
        "coverage_radius": 5000,  # km
        "personnel": 200,
        "status": "active"
    },
    "THAAD_Guam": {
        "interceptor_type": "THAAD",
        "capacity": 48,
        "response_time": 60,
        "coverage_radius": 200,
        "personnel": 100,
        "status": "active"
    }
}

# Site state machine (like NodeState)
enum SiteState { PENDING, ACTIVE, DEGRADED, DESTROYED }

# Site management (like Hypervisor interface)
func create_site(site_id: String, config: Dictionary) -> DefenseSite:
    # Deploy new defense battery
    
func destroy_site(site_id: String) -> void:
    # Remove destroyed site
    
func activate_site(site_id: String) -> void:
    # Bring site online
    
func deactivate_site(site_id: String) -> void:
    # Take site offline for maintenance
    
func list_sites() -> Array:
    # Get all sites
    
func get_site_status(site_id: String) -> Dictionary:
    # Get interceptor count, readiness, damage
```

#### Implementation Files:

```
norad-war-simulator/
├── scripts/systems/
│   ├── defense_site_manager.gd     # NEW - Site management
│   ├── defense_site_config.gd      # NEW - Site configurations
│   └── defense_site_status.gd      # NEW - Status tracking
├── data/
│   └── defense_sites.json          # NEW - Site data
```

---

### Phase 2: Auto-Intercept Doctrine (Weeks 3-4)

**Goal:** Use vimic2's AutoScaler for automated defense response.

#### From vimic2:
```go
// AutoScaler rules
type ScaleRule struct {
    ClusterID       string
    Metric          string        // "cpu", "memory"
    UpperThreshold  float64
    LowerThreshold  float64
    ScaleUpCount    int
    ScaleDownCount  int
    Cooldown        time.Duration
    Enabled         bool
}
```

#### To NORAD:
```gdscript
# AutoInterceptDoctrine - inspired by vimic2 AutoScaler
class_name AutoInterceptDoctrine

# Doctrine rules (like ScaleRule)
var DOCTRINE_RULES := {
    "default": {
        "threat_threshold": 5,      # Number of missiles
        "intercept_count": 1,        # Interceptors per threat
        "priority_order": ["GBI", "THAAD", "Patriot"],
        "cooldown": 30,             # Seconds between launches
        "enabled": true
    },
    "high_threat": {
        "threat_threshold": 10,
        "intercept_count": 2,        # Shoot-look-shoot
        "priority_order": ["GBI", "THAAD"],
        "cooldown": 15,
        "enabled": true,
        "conditions": {
            "defcon": [1, 2],        # Active at DEFCON 1-2
            "threats_per_minute": 5   # High launch rate
        }
    }
}

# Auto-intercept logic (inspired by AutoScaler)
func evaluate_doctrine(threats: Array, sites: Array) -> Array[Dictionary]:
    # Determine which interceptors to launch
    # Based on threat count, type, trajectory
    # Return list of {site_id, interceptor_type, target_id}
    
func scale_response(threat_level: float) -> void:
    # Increase/decrease auto-intercept aggression
    # Like ScaleUp/ScaleDown
```

---

### Phase 3: Regional Defense Network (Weeks 5-6)

**Goal:** Use vimic2's ClusterManager for coordinated defense.

#### From vimic2:
```go
// Cluster Manager
type ClusterManager struct {
    clusters map[string]*Cluster
}

type Cluster struct {
    ID       string
    Nodes    []*Node
    Status   ClusterStatus
    Strategy string  // "balanced", "priority", "backup"
}
```

#### To NORAD:
```gdscript
# RegionalDefenseNetwork - inspired by ClusterManager
class_name RegionalDefenseNetwork

# Defense regions (like clusters)
var DEFENSE_REGIONS := {
    "NORAD_North": {
        "sites": ["GBI_Fort_Greely", "GBI_Vandenberg"],
        "coverage": ["Canada", "Alaska", "Northern US"],
        "strategy": "priority",  # Primary site first, then backup
        "status": "active"
    },
    "NORAD_Pacific": {
        "sites": ["THAAD_Guam", "THAAD_SouthKorea", "Patriot_Japan"],
        "coverage": ["Pacific", "Japan", "South Korea"],
        "strategy": "balanced",  # Distribute threats across sites
        "status": "active"
    }
}

# Regional coordination (like Cluster strategy)
func assign_threat_to_region(threat: Missile) -> DefenseSite:
    # Find best region for threat
    # Apply regional strategy
    # Return best site
    
func balance_regional_load() -> void:
    # Redistribute interceptors between regions
    # Like cluster load balancing
```

---

### Phase 4: Command Center AI (Weeks 7-8)

**Goal:** Use vimic's Cicerone AI client for in-game AI advisor.

#### From vimic:
```go
// Cicerone AI Client
type CiceroneClient interface {
    Chat(ctx context.Context, req *ChatRequest) (*ChatResponse, error)
    Execute(ctx context.Context, cmd string) (*CommandResult, error)
    GetStatus(ctx context.Context) (*VMStatus, error)
}
```

#### To NORAD:
```gdscript
# CommandCenterAI - inspired by Cicerone AI client
class_name CommandCenterAI

# AI Advisor that provides tactical suggestions
# Similar to how Cicerone provides VM management suggestions

var AI_RESPONSES := {
    "threat_detected": [
        "Multiple missiles detected. Recommend DEFCON 3.",
        "Threat vector identified. THAAD sites on alert.",
        "Launch signatures confirmed. Activating auto-intercept."
    ],
    "intercept_success": [
        "Intercept successful. Threat neutralized.",
        "Target destroyed. Stand down.",
        "Good hit. Remaining threats: {count}."
    ],
    "site_destroyed": [
        "{site_name} has been destroyed. Rerouting to backup.",
        "We lost {site_name}. Regional coverage degraded.",
        "Enemy has neutralized {site_name}. Recommend retaliation?"
    ],
    "defcon_change": [
        "DEFCON {level} declared. All forces on alert.",
        "Presidential authorization received. DEFCON {level}.",
        "Threat level increased. DEFCON {level} effective immediately."
    ]
}

# AI chat interface (like Cicerone Chat)
func process_command(input: String) -> String:
    # Natural language command processing
    # "launch interceptors at threat 1"
    # "show defense status"
    # "recommend intercept strategy"
    
func get_tactical_advice(situation: Dictionary) -> String:
    # AI suggests best course of action
    # Based on current threats, resources, sites
```

---

### Phase 5: Site Metrics & Readiness (Weeks 9-10)

**Goal:** Use vimic's Metrics system for site monitoring.

#### From vimic:
```go
// Metrics
type Metrics struct {
    CPU       float64
    Memory    float64
    Disk      float64
    NetworkRX float64
    NetworkTX float64
    Timestamp time.Time
}
```

#### To NORAD:
```gdscript
# SiteReadiness - inspired by vimic Metrics
class_name SiteReadiness

# Defense site metrics (like VM metrics)
var INTERCEPTOR_METRICS := {
    "GBI_Fort_Greely": {
        "interceptors_available": 40,
        "interceptors_total": 44,
        "launch_success_rate": 0.85,
        "avg_response_time": 120,    # seconds
        "personnel_readiness": 0.95,
        "equipment_status": "operational",
        "last_maintenance": "2024-03-15"
    }
}

# Real-time monitoring (like Metrics)
func get_site_metrics(site_id: String) -> Dictionary:
    # Return current site status
    # Interceptors available, response time, readiness
    
func calculate_regional_readiness(region: String) -> float:
    # Aggregate readiness across sites
    # Like cluster health check
    
func alert_low_readiness() -> void:
    # Notify when readiness drops
    # Like alerting in vimic2
```

---

## Test Suite Integration

### From vimic2 Test Patterns

vimic2 has comprehensive tests for:
- AutoScaler rules
- Cluster management
- Orchestrator behavior
- Deployment wizard

### Apply to NORAD:

```gdscript
# test_defense_site.gd - Inspired by vimic2 tests
extends GutTest

func test_create_site():
    var manager = DefenseSiteManager.new()
    var site = manager.create_site("test_site", {
        "interceptor_type": "GBI",
        "capacity": 40
    })
    assert_eq(site.interceptor_type, "GBI")
    assert_eq(site.capacity, 40)

func test_auto_intercept_doctrine():
    var doctrine = AutoInterceptDoctrine.new()
    doctrine.add_rule("test", {
        "threat_threshold": 5,
        "intercept_count": 1
    })
    var rule = doctrine.get_rule("test")
    assert_eq(rule.threat_threshold, 5)

func test_regional_coordination():
    var network = RegionalDefenseNetwork.new()
    network.add_region("test_region", {
        "sites": ["site1", "site2"],
        "strategy": "balanced"
    })
    var threat = Missile.new()
    var site = network.assign_threat_to_region(threat)
    assert_not_null(site)
```

---

## Implementation Priority

### High Priority (Core Gameplay)
1. **DefenseSiteManager** - Essential for site management
2. **AutoInterceptDoctrine** - Core AI mechanic
3. **SiteReadiness** - Strategic depth

### Medium Priority (Enhanced Gameplay)
4. **RegionalDefenseNetwork** - Coordination mechanics
5. **CommandCenterAI** - Narrative/immersion

### Low Priority (Polish)
6. **Advanced Metrics** - Analytics
7. **AI Voice Lines** - Atmosphere

---

## File Structure After Integration

```
norad-war-simulator/
├── scripts/
│   ├── systems/
│   │   ├── defense_site_manager.gd     # NEW
│   │   ├── auto_intercept_doctrine.gd  # NEW
│   │   ├── regional_network.gd          # NEW
│   │   ├── site_readiness.gd            # NEW
│   │   ├── defense_manager.gd          # EXISTING (enhanced)
│   │   └── ballistic_physics.gd        # EXISTING
│   ├── autoload/
│   │   ├── command_center_ai.gd        # NEW
│   │   └── game_state.gd               # EXISTING
│   └── ui/
│       ├── defense_status_ui.gd         # NEW
│       └── ai_advisor_ui.gd             # NEW
├── data/
│   ├── defense_sites.json              # NEW
│   ├── doctrine_rules.json             # NEW
│   └── ai_responses.json                # NEW
└── tests/
    ├── test_defense_site.gd             # NEW
    ├── test_doctrine.gd                 # NEW
    └── test_regional_network.gd          # NEW
```

---

## Timeline

| Week | Task | vimic Inspiration |
|------|------|-------------------|
| 1 | DefenseSiteManager infrastructure | Hypervisor interface |
| 2 | Site configuration & state | NodeConfig, NodeState |
| 3 | AutoInterceptDoctrine | AutoScaler rules |
| 4 | Doctrine evaluation logic | ScaleUp/ScaleDown |
| 5 | RegionalDefenseNetwork | ClusterManager |
| 6 | Regional coordination | Strategy patterns |
| 7 | CommandCenterAI | CiceroneClient |
| 8 | AI advisor integration | Chat interface |
| 9 | SiteReadiness metrics | Metrics struct |
| 10 | Testing & polish | Test patterns |

---

## References

- vimic source: `~/stsgym-work/vimic/`
- vimic2 source: `~/stsgym-work/vimic2/`
- norad-war-simulator: `~/stsgym-work/norad-war-simulator/`
- norad-sim-test: `~/stsgym-work/norad-sim-test/`

---

*Created: April 1, 2026*
*Author: Lucky (OpenClaw Agent)*