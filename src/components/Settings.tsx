import { useState } from "react";
import { Save, Eye, EyeOff, Server, CreditCard, Bot, Shield } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { useToast } from "@/hooks/use-toast";

export function Settings() {
  const { toast } = useToast();
  const [showSecrets, setShowSecrets] = useState<Record<string, boolean>>({});
  
  const [config, setConfig] = useState({
    botToken: "7123456789:AAH...",
    yookassaShopId: "123456",
    yookassaSecret: "test_...",
    cryptobotToken: "12345:AAG...",
    tonManifest: "https://yourdomain.com/tonconnect-manifest.json",
    vpnServerIp: "185.123.456.789",
    vpnServerPort: "443",
    adminIds: "123456789",
    enableRecurring: true,
    enableCrypto: true,
    enableTon: true,
  });

  const toggleSecret = (key: string) => {
    setShowSecrets(prev => ({ ...prev, [key]: !prev[key] }));
  };

  const handleSave = () => {
    toast({
      title: "Настройки сохранены",
      description: "Конфигурация бота обновлена",
    });
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold gradient-text">Настройки</h2>
        <p className="text-muted-foreground">Конфигурация бота и платёжных систем</p>
      </div>

      {/* Telegram Bot */}
      <Card className="bg-card border-border">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Bot className="h-5 w-5 text-primary" />
            Telegram Bot
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label>Bot Token</Label>
            <div className="relative">
              <Input
                type={showSecrets.botToken ? "text" : "password"}
                value={config.botToken}
                onChange={(e) => setConfig(prev => ({ ...prev, botToken: e.target.value }))}
                className="pr-10 bg-muted border-border font-mono"
              />
              <Button
                size="icon"
                variant="ghost"
                className="absolute right-1 top-1/2 -translate-y-1/2 h-8 w-8"
                onClick={() => toggleSecret("botToken")}
              >
                {showSecrets.botToken ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
              </Button>
            </div>
          </div>
          <div className="space-y-2">
            <Label>Admin Telegram IDs (через запятую)</Label>
            <Input
              value={config.adminIds}
              onChange={(e) => setConfig(prev => ({ ...prev, adminIds: e.target.value }))}
              className="bg-muted border-border font-mono"
              placeholder="123456789, 987654321"
            />
          </div>
        </CardContent>
      </Card>

      {/* Payment Systems */}
      <Card className="bg-card border-border">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <CreditCard className="h-5 w-5 text-accent" />
            Платёжные системы
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* YooKassa */}
          <div className="space-y-4 p-4 rounded-lg bg-muted/30 border border-border">
            <div className="flex items-center justify-between">
              <h4 className="font-medium flex items-center gap-2">
                <span className="w-3 h-3 rounded-full bg-primary" />
                YooKassa (Юкасса)
              </h4>
              <div className="flex items-center gap-2">
                <Label htmlFor="recurring" className="text-sm text-muted-foreground">Рекуррент</Label>
                <Switch
                  id="recurring"
                  checked={config.enableRecurring}
                  onCheckedChange={(checked) => setConfig(prev => ({ ...prev, enableRecurring: checked }))}
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Shop ID</Label>
                <Input
                  value={config.yookassaShopId}
                  onChange={(e) => setConfig(prev => ({ ...prev, yookassaShopId: e.target.value }))}
                  className="bg-muted border-border font-mono"
                />
              </div>
              <div className="space-y-2">
                <Label>Secret Key</Label>
                <div className="relative">
                  <Input
                    type={showSecrets.yookassa ? "text" : "password"}
                    value={config.yookassaSecret}
                    onChange={(e) => setConfig(prev => ({ ...prev, yookassaSecret: e.target.value }))}
                    className="pr-10 bg-muted border-border font-mono"
                  />
                  <Button
                    size="icon"
                    variant="ghost"
                    className="absolute right-1 top-1/2 -translate-y-1/2 h-8 w-8"
                    onClick={() => toggleSecret("yookassa")}
                  >
                    {showSecrets.yookassa ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </Button>
                </div>
              </div>
            </div>
          </div>

          {/* CryptoBot */}
          <div className="space-y-4 p-4 rounded-lg bg-muted/30 border border-border">
            <div className="flex items-center justify-between">
              <h4 className="font-medium flex items-center gap-2">
                <span className="w-3 h-3 rounded-full bg-secondary" />
                CryptoBot
              </h4>
              <div className="flex items-center gap-2">
                <Label htmlFor="crypto" className="text-sm text-muted-foreground">Включить</Label>
                <Switch
                  id="crypto"
                  checked={config.enableCrypto}
                  onCheckedChange={(checked) => setConfig(prev => ({ ...prev, enableCrypto: checked }))}
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>API Token</Label>
              <div className="relative">
                <Input
                  type={showSecrets.cryptobot ? "text" : "password"}
                  value={config.cryptobotToken}
                  onChange={(e) => setConfig(prev => ({ ...prev, cryptobotToken: e.target.value }))}
                  className="pr-10 bg-muted border-border font-mono"
                />
                <Button
                  size="icon"
                  variant="ghost"
                  className="absolute right-1 top-1/2 -translate-y-1/2 h-8 w-8"
                  onClick={() => toggleSecret("cryptobot")}
                >
                  {showSecrets.cryptobot ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </Button>
              </div>
            </div>
          </div>

          {/* TON Connect */}
          <div className="space-y-4 p-4 rounded-lg bg-muted/30 border border-border">
            <div className="flex items-center justify-between">
              <h4 className="font-medium flex items-center gap-2">
                <span className="w-3 h-3 rounded-full bg-accent" />
                TON Connect
              </h4>
              <div className="flex items-center gap-2">
                <Label htmlFor="ton" className="text-sm text-muted-foreground">Включить</Label>
                <Switch
                  id="ton"
                  checked={config.enableTon}
                  onCheckedChange={(checked) => setConfig(prev => ({ ...prev, enableTon: checked }))}
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>Manifest URL</Label>
              <Input
                value={config.tonManifest}
                onChange={(e) => setConfig(prev => ({ ...prev, tonManifest: e.target.value }))}
                className="bg-muted border-border font-mono"
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* VPN Server */}
      <Card className="bg-card border-border">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Server className="h-5 w-5 text-secondary" />
            VPN Сервер
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>IP адрес сервера</Label>
              <Input
                value={config.vpnServerIp}
                onChange={(e) => setConfig(prev => ({ ...prev, vpnServerIp: e.target.value }))}
                className="bg-muted border-border font-mono"
              />
            </div>
            <div className="space-y-2">
              <Label>Порт</Label>
              <Input
                value={config.vpnServerPort}
                onChange={(e) => setConfig(prev => ({ ...prev, vpnServerPort: e.target.value }))}
                className="bg-muted border-border font-mono"
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Save Button */}
      <div className="flex justify-end">
        <Button variant="cyber" size="lg" onClick={handleSave} className="gap-2">
          <Save className="h-5 w-5" />
          Сохранить настройки
        </Button>
      </div>
    </div>
  );
}
