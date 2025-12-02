import { useState } from "react";
import { Sidebar } from "@/components/Sidebar";
import { Dashboard } from "@/components/Dashboard";
import { Documentation } from "@/components/Documentation";
import { UsersTable } from "@/components/UsersTable";
import { Settings } from "@/components/Settings";
import { FullGuide } from "@/components/FullGuide";
import { Menu, X } from "lucide-react";
import { Button } from "@/components/ui/button";

const Index = () => {
  const [activeTab, setActiveTab] = useState("dashboard");
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const renderContent = () => {
    switch (activeTab) {
      case "dashboard":
        return <Dashboard />;
      case "docs":
        return <Documentation />;
      case "guide":
        return <FullGuide />;
      case "users":
        return <UsersTable />;
      case "settings":
        return <Settings />;
      case "payments":
        return (
          <div className="flex items-center justify-center h-64">
            <p className="text-muted-foreground">Раздел платежей в разработке</p>
          </div>
        );
      case "keys":
        return (
          <div className="flex items-center justify-center h-64">
            <p className="text-muted-foreground">Управление ключами в разработке</p>
          </div>
        );
      case "servers":
        return (
          <div className="flex items-center justify-center h-64">
            <p className="text-muted-foreground">Мониторинг серверов в разработке</p>
          </div>
        );
      default:
        return <Dashboard />;
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Background Pattern */}
      <div className="fixed inset-0 bg-grid-pattern bg-[size:50px_50px] opacity-5 pointer-events-none" />
      
      {/* Mobile Header */}
      <div className="lg:hidden fixed top-0 left-0 right-0 z-50 bg-card border-b border-border p-4">
        <div className="flex items-center justify-between">
          <h1 className="font-bold text-lg gradient-text">VPN Bot Admin</h1>
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setSidebarOpen(!sidebarOpen)}
          >
            {sidebarOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
          </Button>
        </div>
      </div>

      {/* Mobile Sidebar Overlay */}
      {sidebarOpen && (
        <div 
          className="lg:hidden fixed inset-0 bg-background/80 backdrop-blur-sm z-40"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      <div className="flex">
        {/* Sidebar */}
        <div className={`
          fixed lg:static inset-y-0 left-0 z-50
          transform lg:transform-none transition-transform duration-300
          ${sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
        `}>
          <Sidebar activeTab={activeTab} setActiveTab={(tab) => {
            setActiveTab(tab);
            setSidebarOpen(false);
          }} />
        </div>

        {/* Main Content */}
        <main className="flex-1 p-6 lg:p-8 mt-16 lg:mt-0">
          <div className="max-w-7xl mx-auto animate-fade-in">
            {renderContent()}
          </div>
        </main>
      </div>
    </div>
  );
};

export default Index;
