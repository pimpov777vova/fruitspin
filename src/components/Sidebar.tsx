import { 
  LayoutDashboard, 
  Users, 
  CreditCard, 
  Key, 
  Settings, 
  FileText,
  Server,
  Shield,
  BookOpen
} from "lucide-react";
import { cn } from "@/lib/utils";

interface SidebarProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const menuItems = [
  { id: "dashboard", label: "Дашборд", icon: LayoutDashboard },
  { id: "users", label: "Пользователи", icon: Users },
  { id: "payments", label: "Платежи", icon: CreditCard },
  { id: "keys", label: "Ключи", icon: Key },
  { id: "servers", label: "Серверы", icon: Server },
  { id: "docs", label: "Код бота", icon: FileText },
  { id: "guide", label: "Инструкция", icon: BookOpen },
  { id: "settings", label: "Настройки", icon: Settings },
];

export function Sidebar({ activeTab, setActiveTab }: SidebarProps) {
  return (
    <aside className="w-64 bg-card border-r border-border min-h-screen p-4">
      {/* Logo */}
      <div className="flex items-center gap-3 px-3 py-4 mb-8">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center">
          <Shield className="h-6 w-6 text-primary-foreground" />
        </div>
        <div>
          <h1 className="font-bold text-lg gradient-text">VPN Bot</h1>
          <p className="text-xs text-muted-foreground">Admin Panel</p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="space-y-1">
        {menuItems.map((item) => (
          <button
            key={item.id}
            onClick={() => setActiveTab(item.id)}
            className={cn(
              "w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-200",
              activeTab === item.id
                ? "bg-primary/10 text-primary border border-primary/30"
                : "text-muted-foreground hover:bg-muted hover:text-foreground"
            )}
          >
            <item.icon className="h-5 w-5" />
            <span className="font-medium">{item.label}</span>
          </button>
        ))}
      </nav>

      {/* Status */}
      <div className="absolute bottom-4 left-4 right-4">
        <div className="p-4 rounded-lg bg-muted/50 border border-border">
          <div className="flex items-center gap-2 mb-2">
            <div className="w-2 h-2 rounded-full bg-accent animate-pulse" />
            <span className="text-sm font-medium text-foreground">Бот активен</span>
          </div>
          <p className="text-xs text-muted-foreground">
            Последняя активность: 2 мин назад
          </p>
        </div>
      </div>
    </aside>
  );
}
